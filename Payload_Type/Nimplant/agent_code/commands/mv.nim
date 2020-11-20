# Moves a file from src to dest

import asyncdispatch
from os import moveFile

proc execute*(src: string, dest: string): Future[bool] {.async.} = 
    moveFile(src, dest)
    result = true
