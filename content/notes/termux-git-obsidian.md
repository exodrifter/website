---
title: Using Git and Obsidian with Termux
created: 2024-10-26T15:42:32Z
aliases:
- Using Git and Obsidian with Termux
tags:
- git
- obsidian
- termux
---

# Using Git and Obsidian with Termux

First, grant permissions to storage: [^2]

```
termux-setup-storage
```

Then, install git and clone the repository to internal device storage: [^1]

```
apt install git
cd /storage/shared/
git clone git@example.com/user/repo
```

To install a custom plugin, you'll have to build it in Termux's home folder since symlinks are not allowed in internal device storage. After building, remember to copy the `main.js` and `manifest.json` files to the obsidian plugin directory. [^3]

[^1]: [20241026150734](../entries/20241026150734.md)
[^2]: [20241026152024](../entries/20241026152024.md)
[^3]: [20241026152423](../entries/20241026152423.md)
