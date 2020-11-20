+++
title = "drives"
chapter = false
weight = 105
hidden = false
+++

## Summary
Get information about mounted drives on Linux hosts only.
 
- Needs Admin: False  
- Version: 1  
- Author: NotoriousRebel

### Arguments

## Usage

```
drives
```

## MITRE ATT&CK Mapping

- T1135  
## Detailed Summary

If on Windows uses GetLogicalDriveStringsW, if on Linux lists paths
that match regex of `"/dev/sd*[a-z]"`