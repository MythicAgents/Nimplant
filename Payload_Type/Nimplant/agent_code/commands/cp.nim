# Copies a file from source to dest preserving file permissions.

import asyncdispatch
from os import copyFileWithPermissions

proc execute*(src: string, dest: string): Future[bool] {.async.} = 
    copyFileWithPermissions(src, dest)
    result = true
