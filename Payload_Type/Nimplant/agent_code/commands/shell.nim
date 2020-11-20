# Execute an arbitrary command using cmd.exe or sh if on Linux
import asyncdispatch
import osproc

proc execute*(command: string) : Future[string] {.async.} = 
    when defined(windows):
        let command = "/r" & command
        when not defined(release):
            echo "command: ", command
        result = execProcess("cmd", args=[command], options={poUsePath})
    when defined(linux):
        when not defined(release):
            echo "command: ", command
        result = execProcess("sh", args=["-c", command], options={poUsePath})