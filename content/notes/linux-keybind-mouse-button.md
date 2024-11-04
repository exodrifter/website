---
title: Hold mouse button down via keybind
created: 2024-11-04T20:32:12Z
aliases:
- Hold mouse button down via keybind
tags:
- linux
---

# Hold mouse button down via keybind

You can hold a mouse button down with key binding by invoking the `xte` command from the `xautomation` package. [^1]

For example, a keyboard shortcut could be configured to run the following command in order to hold down the left mouse button: [^1]

```sh
xte "mousedown 1"
```

[^1]: [20241104202638](entries/20241104202638.md)
