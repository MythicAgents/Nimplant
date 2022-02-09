from base64 import encode
# import streams
import asyncfile, asyncdispatch, os


proc GetTotalChunks*(path: string, ChunkSize: int ): Future[int] {.async.} = 
    let fi = getFileSize(path)
    let total_chunks = uint64(fi + ChunkSize - 1 ) div uint64(ChunkSize)
    result = int(total_chunks)

proc GetFileSize*(path: string): Future[int64] {.async.} = 
    result = getfileSize(path)

proc GetPath*(path: string): Future[string] {.async.} =
    result = absolutePath(path)

proc execute*(path: string, ChunkSize: int, ChunkNum: int, TotalChunks: int, Filesize: int64): Future[string] {.async.} = 
    var size = if TotalChunks == ChunkNum + 1: int(FileSize) - (ChunkNum * TotalChunks) else: ChunkSize
    
    #var strm = newFileStream(path, fmRead)
    var strm = openAsync(path, fmRead)

    var buffer {.noinit.} : seq[char]
    # strm.setPosition(ChunkNum * ChunkSize)
    strm.setFilePos(ChunkNum * ChunkSize)
    
    when not defined(release):
        echo "ChunkSize: ", $(ChunkSize)
        echo "ChunkNum: ", $(ChunkNum)
        echo "TotalChunks: ", $(TotalChunks)
        echo "FileSize: ", $(FileSize)

    buffer = newSeq[char](size)
    #discard readData(strm, addr(buffer[0]), len buffer) 
    discard await readBuffer(strm, addr(buffer[0]), len buffer)

    when not defined(release):
        echo "buffer: ", $(buffer)

    strm.close()
    result = encode(buffer)
