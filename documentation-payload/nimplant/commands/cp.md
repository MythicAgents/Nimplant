+++
title = "cp"
chapter = false
weight = 102
hidden = false
+++

## Summary
Copy a file from one location to another.
  
- Needs Admin: False  
- Version: 1  
- Author: @NotoriousRebel
  
### Arguments

#### source

- Description: Source file to copy.  
- Required Value: True  
- Default Value: None  

#### destination

- Description: Source will copy to this location  
- Required Value: True  
- Default Value: None  

## Usage

```
cp
```


## Detailed Summary

Uses the [copyFileWithPermissions](https://nim-lang.org/docs/os.html#copyDirWithPermissions%2Cstring%2Cstring) proc from Nim's os module.
