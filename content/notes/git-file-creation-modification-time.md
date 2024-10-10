---
title: Getting a file's creation and modification time
created: 2024-10-10T20:37:11Z
aliases:
  - Getting a file's creation and modification time
tags:
  - git
---

# Getting a file's creation and modification time

To get the time a file was first added to a git repository and when it was last modified, use the following command: [^1]

```sh
git log --follow --format=%ad --date iso-strict FILE | sed -n '1p; $p'
```

If you need to be more selective about which commits should count based on what changed, you can view every commit a file was added or modified in along with a diff showing that happened with the following command: [^1]

```sh
git log -p --stat --follow --date iso-strict FILE
```

[^1]: [20241009063425](../entries/20241009063425.md)
