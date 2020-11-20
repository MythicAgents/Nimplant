+++
title = "ps"
chapter = false
weight = 120
hidden = false
+++

## Summary

Get a process listing.

- Needs Admin: False
- Version: 1
- Author: @NotoriousRebel

### Arguments

## Usage

```
ps
```

## MITRE ATT&CK Mapping

- T1057

## Detailed Summary

Obtain a list of running processes, if on Linux by traversing '/proc'. If on Windows uses 'CreateToolhelp32Snapshot', 'Process32First', and 'Process32Next'.
