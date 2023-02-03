import asyncdispatch
from os import envPairs

proc execute*(): Future[seq[string]] {.async.} = 
    var vars: seq[string]
    for key, value in envPairs():
        vars.add(key & ": " & value)
    result = vars