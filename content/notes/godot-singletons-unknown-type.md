---
title: Singleton autoloads have an unknown type
created: 2024-07-03T20:06:52Z
modified: 2024-10-28T05:07:25Z
aliases:
- Singleton autoloads have an unknown type
tags:
- godot
---

# Singleton autoloads have an unknown type

In Godot, if you make a singleton autoload by autoloading a packed scene that has the script attached, the editor will not be able to determine the type of the autoload in [GDScript](../tags/gdscript.md)

To workaround this problem, you will need to tell Godot the type of the autoload.

See: [godotengine/godot#86300](https://github.com/godotengine/godot/issues/86300)

I consider this issue to be a [Godot crime](godot-crimes.md).

# History

- [202403130348](../entries/202403130348.md)
