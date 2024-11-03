---
title: Find disk UUIDs
created: 2024-11-03T17:28:58Z
aliases:
- Find disk UUIDs
- Look up disk UUIDs
tags:
- linux
---

# Find disk UUIDs

To find the UUIDs of disks in Linux, you can use `lsblk`: [^1]

```sh
lsblk -o +UUID
```

[^1]: [20241103172422](../entries/20241103172422.md)
