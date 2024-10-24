---
title: Cannot upload more files to Gitea
created: 2024-10-24T23:26:45Z
aliases:
- Cannot upload more files to Gitea
tags:
- gitea
---

# Cannot upload more files to Gitea

While uploading attachments to a release in Gitea, you might encounter the following error: [^1]

> You can not upload any more files.

Apparently, Gitea has a default limit of 5 attachments for releases. You can change this by changing the value for the `MAX_FILES` setting in the config under `repository.upload`: [^1]

```
[repository.upload]
; Max number of files per upload. Defaults to 5
MAX_FILES = 5
```

[^1]: [20241024232323](../entries/20241024232323.md)
