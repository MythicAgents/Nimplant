import asyncdispatch
import os
import times

type
    FileExtract = object
        path*: string
        Isfile*: bool
        size*: BiggestInt
        permissions*: string
        linkCount*: BiggestInt
        lastAccessTime*: string
        lastWriteTime*: string
        creationTime*: string

proc ExtractInfo(path: string, info: FileInfo): Future[FileExtract] {.async.} = 
    result = FileExtract(path: path , Isfile: if cmp($(info.kind), "pcFile") == 0 : true else: false, size: info.size, 
                              permissions: $(info.permissions), linkCount: info.linkCount, lastAccessTime: $(info.lastAccessTime), 
                              lastWriteTime: $(info.lastWriteTime), creationTime: $(info.creationTime))

proc execute*(path: string, recurse: bool = false): Future[seq[FileExtract]] {.async.} =
    var lst: seq[FileExtract]

    if recurse:
         for path in walkDirRec(path):
            lst.add(await ExtractInfo(path, getFileInfo(path)))
    else:
        for _, path in walkDir(path):            
            lst.add(await ExtractInfo(path, getFileInfo(path)))
    result = lst
    