---
title: "`TextureRect` does not scale nicely"
created: 2024-07-22T22:14:34Z
modified: 2024-09-19T04:26:37Z
aliases:
- "`TextureRect` does not scale nicely"
tags:
- godot
---

# `TextureRect` does not scale nicely

By default, `TextureRect` in Godot uses nearest filtering instead of linear filtering which can cause things in the original texture, like lines, to appear jagged. To change this, you can change the `texture_filter` value from the base`CanvasItem` class.

# History

- [20240722203732](../entries/20240722203732.md)
