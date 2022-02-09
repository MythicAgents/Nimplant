
# Moved Job object here to avoid a circular dependency 
# import tables

type 
   Job* = object
      JobId*: int
      TaskId*: string
      Completed*: bool
      Success*: bool
      JobStarted*: bool
      Command*: string
      Parameters*: string
      Response*: string
      Upload*: bool
      Download*: bool
      Screenshot*: bool
      ScreenshotContents*: string
      ChunkingStarted*: bool
      TotalChunks*: int
      ChunkNum*: int
      WriteNum*: int
      FileId*: string
      FileSize*: int64
      Path*: string
      Chunks*: seq[string]

type 
   Task* = object
      action*: string
      id* : string
      parameters*: string
      timestamp*: float

proc taskCmp*(x, y: Task): int =
   # custom sorting cmp proc for Task objects
   let tone = x.timestamp
   let ttwo = y.timestamp
   if  tone < ttwo: -1
   elif tone == ttwo: 0
   else: 1