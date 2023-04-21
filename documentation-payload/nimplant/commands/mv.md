+++
title = "mv"
chapter = false
weight = 118
hidden = false
+++

## Summary
Move a file from one location to another.

  
- Needs Admin: False  
- Version: 1  
- Author: @NotoriousRebel  

### Arguments

#### source

- Description: Source file to move.  
- Required Value: True  
- Default Value: None  

#### destination

- Description: Source will move to this location  
- Required Value: True  
- Default Value: None  

## Usage

```
mv
```


## Detailed Summary

Uses the [moveFile](https://nim-lang.org/docs/os.html#moveFile%2Cstring%2Cstring) proc from Nim's os module. 
