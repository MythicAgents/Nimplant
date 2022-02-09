# List drives on dvice

import asyncdispatch

when defined(windows):
    # Type definitions from https://github.com/khchen/winim/blob/master/winim/inc/winbase.nim
    type DWORD* = uint32
    type WCHAR* = uint16
    type LPWSTR* = ptr WCHAR
    const MAX_DRIVES* = 27
    proc GetLogicalDriveStringsW (nBufferLength: DWORD, lpBuffer: LPWSTR): DWORD {.cdecl, importc: "GetLogical" & "DriveStringsW", dynlib: "kern" & "el32." & "dll".}
    proc `$`(a: array[MAX_DRIVES, WCHAR]): string = $cast[WideCString](unsafeAddr a[0])
  
when defined(linux):
    # TODO fix port of poseidon's drives_nix.go and replace linux specific logic
    from os import walkPattern
  
proc execute*(): Future[seq[string]] {.async.} = 
    var returnSeq: seq[string]
    when defined(linux):
        for path in walkPattern("/dev/sd*[a-z]"): 
            returnSeq.add(path)
    when defined(windows):
        var buffer: array[MAX_DRIVES, WCHAR]
        discard GetLogicalDriveStringsW(uint32(len(buffer)), addr(buffer[0]))
        returnSeq.add($(buffer))
        
    result = returnSeq
