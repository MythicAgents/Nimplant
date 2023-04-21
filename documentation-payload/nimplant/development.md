+++
title = "Development"
chapter = false
weight = 20
pre = "<b>3. </b>"
+++

## Development Environment

`nimplant` was developed with cross-platform functionality at it's forefront. For a development environment VSCode or a JetBrains IDE with the Nim plugin will suffice or any other text editor. To install Nim follow their [installation page](https://nim-lang.org/install.html) instructions. I used Scoop to install Nim for my development environment. Nim **1.2+** should be used.

## Adding Commands

To add a new command to the `nimplant` there are two things you need to do. First in the commands folder create a new nim file with the name being the command you want to implement. In that file you can have as many helper procs as you want; however, there must be a proc defined as `proc execute*(): Future[return_type] {.async.} = `. The asterisk indicates the proc is exported and this is what will get called in job.nim to actually execute your command. If this command is cross-platform to not add unnecessary size to the agent I recommend following what commands such as ps and shell do in which they use `when defined` to separate platform-specific code as can be seen down below.

```nim
import asyncdispatch

proc execute*(param: string) : Future[string] {.async.} = 
    when defined(linux):
        # Linux command implementation
    when defined(windows):
        # Windows command implementation
```

After your command has been tested inside the utils folder you will need to edit job.nim. In the proc called `jobLauncher` there is a massive switch statement in which you will just need to add a case for your agent in lexicographical order, after that you are good to go. 

