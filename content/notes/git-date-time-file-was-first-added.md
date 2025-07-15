---
title: Get the timestamp a file was first added to a git repository
created: 2025-07-15T06:22:14Z
aliases:
- Get the timestamp a file was first added to a git repository
- Get the date time a file was first added to a git repository
tags:
- git
---

# Get the timestamp a file was first added to a git repository

To get the timestamp a file was first added to a git repository, use the following command: [^1]

```sh
git log --follow --format=%ad --date default <FILE> | tail -1
```

For a timestamp in ISO 8601 format, use `iso-strict` instead of `default`. [^1]

[^1]: [20250715061842](../entries/20250715061842.md)
