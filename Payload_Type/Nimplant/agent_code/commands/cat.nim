# Given a file path read the contents
import asyncdispatch, asyncfile

proc execute*(path: string): Future[string] {.async.} = 
    # result = readFile(path)
    var file = openAsync(path, fmRead)
    result = await file.readAll()
    file.close()
    