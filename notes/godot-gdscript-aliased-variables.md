---
aliases:
- Exported variables of inherited scenes are aliased
---

# Exported variables of inherited scenes are aliased

In Godot 4.2 or earlier, exported variables in inherited scenes are aliased.

For example, if you have a scene which inherits another and that scene exports a `Dictionary` variable, that variable will share the same `Dictionary` reference among all instances of that scene.

This issue has been fixed for Godot 4.3 (see [godotengine/godot#88741](https://github.com/godotengine/godot/pull/88741)).

## History

![20240222_2021](../entries/20240222_2021.md)

![20240703_194355](../entries/20240703_194355.md)
