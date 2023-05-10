import asyncdispatch
import os
import times
import std/marshal
import json

type PermInfo = object
    user: string
    group: string
    other: string

type        
    SubFileInfo = object
        is_file*: bool
        permissions*: PermInfo
        name*: string
        access_time*: int64
        modify_time*: int64
        size*: BiggestInt 

type
    FileExtract = object
        #path*: string
        is_file*: bool
        size*: BiggestInt
        permissions*: PermInfo
        linkCount*: BiggestInt
        access_time*: int64
        modify_time*: int64
        creationTime*: int64
        host*:string
        parent_path*:string
        name*:string
        success*:bool
        update_deleted*: bool
        files*: seq[SubFileInfo]

proc getPermJson(fileinfo: FileInfo): PermInfo =
    var permuser = ""
    var permgroup = ""
    var permother = ""

    for i,fp in [fpUserRead,fpUserWrite,fpUserExec]:
        permuser.add(if fp in fileinfo.permissions: "rwx"[i mod 3] else: '-')
    for i,fp in [fpGroupRead,fpGroupWrite,fpGroupExec]:
        permgroup.add(if fp in fileinfo.permissions: "rwx"[i mod 3] else: '-')
    for i,fp in [fpOthersRead,fpOthersWrite,fpOthersExec]:
        permother.add(if fp in fileinfo.permissions: "rwx"[i mod 3] else: '-')        

    result = PermInfo(user:permuser,group:permgroup,other:permother)


proc ExtractInfo(parampath: string, info: FileInfo,host:string): Future[string] {.async.} = 
    var filepath  = ""
    
    filepath = absolutePath(parampath)

    let fileinfo = info
    var isFile = cmp($(fileinfo.kind), "pcFile") == 0
    var (path,name,ext) = splitFile(filepath)
    var subFiles : seq[SubFileInfo]
    

    if not isFile:
        for _, subfile in walkDir(filepath):
            try:
                let (_,subname,subext) = splitFile(subfile)
                var subinfo = getFileInfo(subfile)
                subFiles.add(SubFileInfo(is_file:(cmp($(subinfo.kind), "pcFile") == 0),permissions: getPermJson(subinfo),name:subname & subext,
                access_time: subinfo.lastAccessTime.toUnix(),modify_time: subinfo.lastWriteTime.toUnix(),size: subinfo.size))
            except OSError:
                #if not defined(release):
                #    echo "error getting info on ", name
                #else:
                #    discard
                discard

    result = $$(FileExtract(parent_path:  if isRootDir(filepath): "" else: parentDir(filepath) & $os.DirSep, is_file: isFile, size: fileinfo.size, 
                              permissions: getPermJson(fileinfo), success:true, linkCount: fileinfo.linkCount, access_time: fileinfo.lastAccessTime.toUnix(), 
                              modify_time: fileinfo.lastWriteTime.toUnix(), creationTime: fileinfo.creationTime.toUnix(),host:host,name:if isRootDir(filepath): filepath else: name & ext,update_deleted:true,files:subFiles))


proc execute*(path: string, recurse: bool = false,host:string): Future[string] {.async.} =
    
    result = await ExtractInfo(path, getFileInfo(path),host)
    
    
    