---
title: "`_physics_process(_delta)` doesn't work after teleporting"
created: 2023-07-26T10:47Z
aliases:
- "`_physics_process(_delta)` doesn't work after teleporting"
tags:
- godot
---

# `_physics_process(_delta)` doesn't work after teleporting

> [!question]
> After I manually change the parent of my `CharacterBody2D`, `_physics_process(_delta)` is not being called even though it is overridden.

If the parent of the `CharacterBody2D` is changed, this can result in `_physics_process(_delta)` no longer being called. Re-enable the callback by calling `set_physics_process(true)`. [^1]

[^1]: [202307261047](../entries/202307261047.md)
