# Upload file 
import asyncfile, asyncdispatch, os
import base64
# import streams
   
proc execute*(contents: string, path: string): Future[bool] {.async.} = 
    #var strm = newFileStream(path, fmWrite)
    var strm = openAsync(path, fmWrite)
    let pos = if fileExists(path): int(getfileSize(path)) else: 0
    #strm.setPosition(pos)
    strm.setFilePos(pos)
    let decoded = decode(contents)
    # strm.write(decoded)
    await strm.write(decoded)
    strm.close()
    result = true
