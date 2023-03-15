import asyncdispatch
from os import createDir

proc execute*(dir: string): Future[bool] {.async.} = 
    createDir(dir)
    result = true