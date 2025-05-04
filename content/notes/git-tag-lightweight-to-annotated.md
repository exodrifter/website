---
title: Convert lightweight tags to annotated tags
created: 2025-05-04T01:51:29Z
aliases:
- Convert lightweight tags to annotated tags
tags:
- git
---

# Convert lightweight tags to annotated tags

To convert lightweight tags to annotated tags in [Git](../tags/git.md): [^1]

```bash
#!/bin/bash

for tag in `git tag`; do
    date="$(git show $tag^0 -s --format=%aD)"
    GIT_COMMITTER_DATE="$date" git tag -a -f $tag $tag^0
done
```

[^1]: [20250504014335](../entries/20250504014335.md)