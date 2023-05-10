# List current processes

when defined(linux):
  # Mostly a port from poseidon's logic 
  import asyncdispatch
  import json
  from strformat import fmt
  import os
  import posix
  from strutils import isDigit, parseInt
  type
    UnixProcess = object
        pid*: int
        ppid*: int
        state*: int32
        pgrp*:  int
        sid*:  int
        architecture*: string
        binary*: string
        owner*: string
        bin_path*: string  

  proc getProcessCmdline(pid: int): string =
      let path = fmt"/proc/{pid}/cmdline"
      result = readFile(path)

  proc getProcessOwner(pid: int): string = 
      let path = fmt"/proc/{pid}/status"
      let file = open(path)
      defer: close(file)
      let handle = getFileHandle(file)
      var fileStat: Stat
      let fstatResult = fstat(handle, fileStat)
      let userPasswd = getpwuid(filestat.st_uid)
      result = $userPasswd.pw_name
  
  # proc findProcesses(pid: int): string = 
  #    let processSeq = getProcesses()        
  #    result = ""

  proc getProcesses*(): seq[UnixProcess] =
      var procSeq: seq[UnixProcess]
      for kind, path in walkDir("/proc"): 
        if kind != pcDir: 
           # Only care about directories
           continue           
        var process: UnixProcess
        let info = getFileInfo(path)
        let name = path
        let numinName = name[6 .. ^1]
        if not isDigit(numinName[0]):
           continue
        let pid = parseInt(numinName)
        process.pid = pid
        process.owner = getProcessOwner(pid)
        process.bin_path = getProcessCmdline(pid)
        procSeq.add(process)

      result = procSeq

when defined(windows):
  import asyncdispatch
  import json
  import winim/lean
  from winim/extra import PROCESSENTRY32, PROCESSENTRY32W, CreateToolhelp32Snapshot, Process32First, Process32Next
  
  proc `$`(a: array[MAX_PATH, WCHAR]): string = $cast[WideCString](unsafeAddr a[0])

proc execute*(): Future[string] {.async.} = 
  when defined(linux):
    var output: string
    let unixProcesses = getProcesses()
    output = output & "["
    for process in unixProcesses:
        let j = %*{"process_id": $(process.pid), "architecture": "", "name": "", "user": process.owner, "bin_path": process.bin_path, "parent_process_id": ""}
        output = output & $(j) & ","

    output = output[0 .. ^2] & "]" 
    result = output
  when defined(windows):
    # https://forum.nim-lang.org/t/580
    var processEntries: seq[PROCESSENTRY32W]
    var output: string
    # 0x00000002 = Process
    let hProcessSnap  = CreateToolhelp32Snapshot(0x00000002, 0)
    var procEntry: PROCESSENTRY32
    procEntry.dwSize = sizeof(PROCESSENTRY32).DWORD
    if Process32First(hProcessSnap, procEntry.addr):
        while Process32Next(hProcessSnap, procEntry.addr):
            processEntries.add(procEntry)
    CloseHandle(hProcessSnap) 
    output = output & "["
    for procEntry in processEntries:
      let j = %*{"process_id": procEntry.th32ProcessID, "architecture": "", "name": $(procEntry.szExeFile), "user": "", "bin_path": "", "parent_process_id": procEntry.th32ParentProcessID}
      output = output & $(j) & ","    
    output = output[0 .. ^2] & "]"
    # delete last comma in json to properly format json
    result = output

