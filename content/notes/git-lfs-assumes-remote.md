---
title: Git LFS assumes the default remote
created: 2024-11-06T03:38:03Z
aliases:
- Git LFS assumes the default remote
tags:
- git
---

# Git LFS assumes the default remote

`git` does not supply remote information to `git lfs`, so it has to assume the remote that you're using. This may cause problems if you are using multiple remotes, as it will cause commands like `git checkout` to fail since `git lfs` will try to fetch the files from the wrong remote. [^1]

To work around this issue, you can manually [fetch LFS assets from another remote](git-lfs-fetch-assets-from-remote.md). [^1]

[^1]: [20241106031816](../entries/20241106031816.md)
