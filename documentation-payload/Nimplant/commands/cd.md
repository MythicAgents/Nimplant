+++
title = "cd"
chapter = false
weight = 101
hidden = false
+++

## Summary
Change working directory (can be relative, but no ~).

- Needs Admin: False  
- Version: 1  
- Author: @NotoriousRebel  

### Arguments

#### path

- Description: path to change directory to  
- Required Value: True  
- Default Value: None  

## Usage

```
cd [path]
```

## MITRE ATT&CK Mapping

- T1005  
## Detailed Summary

Uses the [setCurrentDir](https://nim-lang.org/docs/os.html#setCurrentDir%2Cstring) proc from Nim's os module. 
