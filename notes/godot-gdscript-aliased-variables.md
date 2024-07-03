---
aliases:
- Exported variables of inherited scenes are aliased
---

# Exported variables of inherited scenes are aliased

In [Godot](godot.md) 4.2 or earlier, [GDScript](godot-gdscript.md) variables marked as exported in inherited scenes are aliased.

For example, if you have a scene which inherits another and that scene exports a `Dictionary` variable, that variable will share the same `Dictionary` reference among all instances of that scene.

This issue has been fixed for [Godot](godot.md) 4.3 (see [godotengine/godot#88741](https://github.com/godotengine/godot/pull/88741)).

I consider this issue to be a [Godot crime](godot-crimes.md).

## History

![20240222_2021](../entries/20240222_2021.md)

![20240703_194355](../entries/20240703_194355.md)
