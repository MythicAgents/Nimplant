from os import tryRemoveFile
import asyncdispatch

proc execute*(path: string): Future[bool] {.async.} = 
    result = tryRemoveFile(path)