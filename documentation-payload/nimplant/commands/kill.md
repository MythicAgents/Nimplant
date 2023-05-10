+++
title = "kill"
chapter = false
weight = 114
hidden = false
+++

## Summary

Kill a process specified by PID.

- Needs Admin: False
- Version: 1
- Author: @NotoriousRebel

### Arguments

## Usage

```
kill [pid]
```

## Detailed Summary

Kill a process, if on Windows uses 'OpenProcess' and 'TerminateProcess. If on Linux sends a 'SIGKILL' to the PID.
