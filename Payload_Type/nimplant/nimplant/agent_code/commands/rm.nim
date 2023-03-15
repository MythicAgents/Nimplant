from os import tryRemoveFile
import asyncdispatch

proc execute*(path: string,host: string): Future[bool] {.async.} = 
    result = tryRemoveFile(path)