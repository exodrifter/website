---
title: Application is damaged and cannot be opened
created: 2025-06-10T05:24:34Z
aliases:
- Application is damaged and cannot be opened
tags:
- mac-os
---

# Application is damaged and cannot be opened

If you download an unsigned application and try to open it on MacOS, you can see an error like the following:

> **"application" is damaged and can't be opened. You should move it to the Trash.**
> Firefox downloaded this file today at XX:XX.

The application is not actually damaged; it has been quarantined. To fix this issue, run the following command in a terminal:

```
xattr -dr com.apple.quarantine "application.app"
```

[^1]: [20250610051240](../entries/20250610051240.md)
