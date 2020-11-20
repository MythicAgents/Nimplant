import asyncdispatch
from os import setCurrentDir

proc execute*(newDir: string): Future[bool] {.async.} = 
    setCurrentDir(newDir)
    result = true