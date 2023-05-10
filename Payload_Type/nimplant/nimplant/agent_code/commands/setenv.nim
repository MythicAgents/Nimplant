import asyncdispatch
from os import putEnv

proc execute*(key: string, value: string): Future[bool] {.async.} = 
    putEnv(key, value)
    result = true