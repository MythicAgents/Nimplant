# Helpful functions for cryptography
# Only need to compile these functions
# When psk is defined

when defined(AESPSK):
    import nimcrypto/rijndael
    import nimcrypto/bcmode
    import nimcrypto/hmac
    import sysrandom
    import base64
    from sequtils import concat, repeat

    # Conversion taken from
    # https://github.com/nim-lang/Nim/issues/14810
    proc toString*(buf: seq[byte]): string = move cast[ptr string](buf.unsafeAddr)[]
    proc toByteSeq*(data: string): seq[byte] = move cast[ptr seq[byte]](data.unsafeAddr)[]

    # Unpad a buffer with bytes as defined in PKCS#7
    # Port of https://github.com/paultag/go-pkcs7/blob/master/unpad.go
    proc unpad_buffer*(data: seq[byte], blockSize: uint): seq[byte] = 
        var buffer: seq[byte]
        if blockSize < 1: 
            when not defined(release):
                echo "Block size looks wrong"
            return buffer

        if uint(len(data)) mod blockSize != 0:
            when not defined(release):
                echo "Data isn't aligned to blockSize"
            return buffer
        
        let paddingLength = int(data[^1])
        for i in 0..uint32(data[len(data) - paddingLength]):
            let el = data[i]
            if el != byte(paddingLength):
                when not defined(release):
                    echo "Padding had malformed entries. Have: ",  $(paddingLength),  " expected: ",  $(el)
            result = buffer

        let num =  len(data) - paddingLength
        result = data[0..num]

    proc pad_buffer*(data: seq[byte], blockSize: uint):  seq[byte] = 
        let neededBytes = blockSize - (uint(len(data)) mod blockSize)
        result = concat(data, repeat(byte(neededBytes), int(neededBytes)))

    proc genIV(length: int): seq[byte] = 
        defer: closeRandom()
        var buffer = newSeq[byte](length)
        getRandomBytes(addr buffer[0], length)
        result = buffer

    proc encryptStr*(uuid: string, key: string, input: string): string = 
        # So many hours in agony debugging this...
        # Make sure to use raw bytes of sha256 hash result not the string...
        var ctx: CBC[aes256]
        var iv = genIV(16)
        let keyBytes = toByteSeq(decode(key))
        ctx.init(keyBytes, iv)
        var cpInput = input
        var paddedInput = toByteSeq(cpInput)
        # pad plaintext
        var plain = pad_buffer(paddedInput, 16)
        let length = len(plain)
        var ecrypt = newSeq[uint8](length)
        ctx.encrypt(plain, ecrypt)    
        let encrypted = concat(iv, ecrypt)
        var hctx1: HMAC[sha256]
        hctx1.init(decode(key))
        hctx1.update(toString(encrypted))
        var hmacres {.noinit.} = newSeq[byte](32)
        discard finish(hctx1, addr(hmacres[0]), 32)
        result = encode(concat(toByteSeq(uuid), encrypted, hmacres), false)
        ctx.clear()
        hctx1.clear()

    proc decryptStr*(uuid: string, key: string, input: string): string = 
        # Get plaintext from base64 formatted encrypted input
        let decoded = decode(input)
        let uuidLen = len(uuid)
        let passeduuid = decoded[0 .. uuidLen]
        let iv = decoded[uuidLen .. uuidLen + 15]
        let ciphertext = decoded[uuidLen + 16 .. len(decoded) - 33]
        let hmac = decoded[^32 .. ^1] # sha256 hmac at the end
        
        let encrypted = concat(toByteSeq(iv), toByteSeq(ciphertext))
        var hctx1: HMAC[sha256]
        hctx1.init(decode(key))
        hctx1.update(toString(encrypted))
        var hmacres {.noinit.} = newSeq[byte](32)
        discard finish(hctx1, addr(hmacres[0]), 32)
        hctx1.clear()
            
        if encode(hmac) == encode(hmacres):
            var ctx: CBC[aes256]
            let keystr = decode(key)
            ctx.init(keystr, iv)
            let length = len(ciphertext)
            var ecrypt = toByteSeq(ciphertext)
            var dcrypt = newSeq[uint8](length)
            ctx.decrypt(ecrypt, dcrypt)
            # unpad decrypted result
            var realstring = unpad_buffer(dcrypt, 16)
            result = uuid & toString(dcrypt)
            ctx.clear()
        else:
            when not defined(release):
                echo "Hash of hmac and encrypted blob do not match"
            result = ""
            
