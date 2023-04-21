+++
title = "OPSEC"
chapter = false
weight = 10
pre = "<b>1. </b>"
+++

## Considerations

While `nimplant` was not necessarily designed with OPSEC in mind. That does not mean OPSEC is not present and the agent can not be made "stealthier."
To see how to make the agent stealthier and things to keep in mind read this post: [here](https://secbytes.net/Implant-Roulette-Part-1:-Nimplant).

### Post-Exploitation Jobs

All post-exploitation jobs ran by `nimplant` are executed within the agent's process memory space. This limits agent exposure to defensive telemetry by reducing interactions with remote processes. This comes with a risk of jobs crashing an agent's process. To combat this risk, `nimplant` is fully asynchronous to minimize the impact of a crashed job to the agent's main executing thread as well as all commands when executed are wrapped inside a try-except block.

### Remote Process Injection

`nimplant` does not currently have a built-in remote process injection method.

### Process Execution

Arbitrary commands can be ran with `nimplant` using the shell command.
Under the hood this is what happens:

```nim
    when defined(windows):
        let command = "/r" & command
        echo "command: ", command
        result = execProcess("cmd", args=[command], options={poUsePath})
    when defined(linux):
        echo "command: ", command
        result = execProcess("sh", args=["-c", command], options={poUsePath})
```
