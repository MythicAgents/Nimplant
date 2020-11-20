# Print current working directory 

import asyncdispatch
from os import getCurrentDir

proc execute*(): Future[string] {.async.} = 
    result = getCurrentDir()
    

