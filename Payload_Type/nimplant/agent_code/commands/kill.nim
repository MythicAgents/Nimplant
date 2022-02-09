# If on Linux kills a process via a SIGKILL signal
# If on Windows uses OpenProcess to obtain a handle then calls TerminateProcess

when defined(windows):
    import winim/lean
    import asyncdispatch
when defined(linux):
    import asyncdispatch
    import osproc    
    from posix import kill, SIGTERM, Pid

proc execute*(pid: int) : Future[bool] {.async.} = 
    when defined(windows):
        # PROCESS_ALL_ACCESS 
        let handle = OpenProcess(0x001F0FFF, false, cast[DWORD](pid))
        result = TerminateProcess(handle, 0)
    when defined(linux):
        var temp: Pid = int32(pid)
        result = if kill(temp, SIGTERM) == 0'i32: true else: false

