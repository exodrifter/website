---
title: Exported variables of inherited scenes are aliased
created: 2024-07-04T14:58:23Z
modified: 2024-10-28T05:11:22Z
aliases:
- Exported variables of inherited scenes are aliased
tags:
- godot
---

# Exported variables of inherited scenes are aliased

> ✅ Fixed
>
> This issue has been fixed for Godot 4.3 (see [godotengine/godot#88741](https://github.com/godotengine/godot/pull/88741)).

In Godot 4.2 or earlier, [GDScript](godot-gdscript.md) variables marked as exported in inherited scenes are aliased.

For example, if you have a scene which inherits another and that scene exports a `Dictionary` variable, that variable will share the same `Dictionary` reference among all instances of that scene. You can get around this issue by manually duplicating the reference in the script.

I consider this issue to be a [Godot crime](godot-crimes.md).

# History

- [20240703194355](../entries/20240703194355.md)
- [i will alias all of your mutable buffers, actually](../blog/20240225042654.md)
- [202402222021](../entries/202402222021.md)
