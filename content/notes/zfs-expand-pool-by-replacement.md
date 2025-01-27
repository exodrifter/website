---
title: Expand a pool in ZFS
created: 2025-01-27T18:41:30Z
tags:
- zfs
---

# Expand a pool in ZFS

To expand a pool by replacing every drive with a larger drive in ZFS, do the following: [^1]

```sh
zpool set autoexpand=on <pool>
zpool replace <pool> <old disk> <new disk>
```

[^1]: [20250127183336](../entries/20250127183336.md)
