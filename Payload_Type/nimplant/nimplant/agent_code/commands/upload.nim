# Upload file 
import asyncfile, asyncdispatch, os
import base64
# import streams
   
proc execute*(contents: string, path: string, append:bool): Future[bool] {.async.} = 

    var strm: AsyncFile
    if (append):
        strm = openAsync(path, fmAppend)
    else:
        strm = openAsync(path, fmWrite)

    let decoded = decode(contents)
    await strm.write(decoded)
    strm.close()

    result = true
