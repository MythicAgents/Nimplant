# Deprecated
This agent is deprecated as it's only compatible with Mythic 2.1 and the main developer is not able to continue working on it. If somebody wants to make the updates (in the python side of things, not nim code) to the latest Mythic, we can mark it as not deprecated anymore.


![Nimplant](agent_icons/nimplant.svg)

Nimplant is a cross-platform (Linux & Windows) implant written in Nim as a fun project to learn about Nim and see what it can bring to the table for red team tool development. Currently, Nimplant lacks extensive evasive tradecraft; however, overtime Nimplant will become much more sophisticated.


## Installation
To install Nimplant, you'll need Mythic installed on a remote computer. You can find installation instructions for Mythic at the [Mythic project page](https://github.com/its-a-feature/Mythic/).

From the Mythic install root, run the command:

`./install_agent_from_github.sh https://github.com/MythicAgents/Nimplant`

Once installed, restart Mythic to build a new agent.


### Highlighted Agent Features
- Cross-platform
- Fully asynchronous
- Can generate agents compiled from both C and C++ source code

## Commands Manual Quick Reference

Command | Syntax | Description
------- | ------ | -----------
cat | `cat [file]` | Retrieve the output of a file.
cd | `cd [dir]` | Change working directory.
cp | `cp [source] [destination]` | Copy a file from source to destination. Modal popup.
curl | `curl [url] [method] [headers] [body]` | Execute a single web request.
download | `download [path]` | Download a file off the target system.
exit | `exit` | Exit a callback.
getenv | `getenv` | Get all of the current environment variables.
jobs | `jobs` | List all running jobs.
kill | `kill [pid]` | Attempt to kill the process specified by `[pid]`.
ls | `ls [path] [recurse]` | List files and folders in `[path]` with optional param to list recursively. Defaults to current working directory.
mkdir | `mkdir [dir]` | Create a directory.
mv | `mv [source] [destination]` | Move a file from source to destination. Modal popup.
ps | `ps` | List process information.
pwd | `pwd` | Print working directory.
rm | `rm [path]` | Remove a file specified by `[path]`
shell | `shell [command]` | Run a shell command which will translate to a process being spawned with command line: `cmd.exe /r[command]`
unsetenv | `setenv [envname] [value]` | Sets an environment variable to your choosing.
sleep | `sleep [seconds]` | Set the callback interval of the agent in seconds.
unsetenv | `unsetenv [envname]` | Unset an environment variable.
upload | `upload` | Upload a file to a remote path on the machine. Modal popup.

## Supported C2 Profiles

Currently, only one C2 profile is available to use when creating a new Nimplant agent: HTTP.

### HTTP Profile

The HTTP profile calls back to the Mythic server over the basic, non-dynamic profile. When selecting options to be stamped into Nimplant at compile time, all options are respected with the exception of those parameters relating to GET requests.

</br>

*More coming soon!*

### Roadmap
- [] Ability to compile to Objective-C for macOS capabilities 
- [] Integration of [Donut](https://github.com/theWover/Donut) to allow user to generate shellcode as output
- [] Communication via WebSockets
- [] Screenshotting capabilities 
- [] Remote process injection capabilities
