import asyncdispatch
from os import delEnv

proc execute*(key: string): Future[bool] {.async.} = 
    delEnv(key)
    result = true