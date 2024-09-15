---
aliases:
- Godot cannot determine the type of autoloads
---

# Godot cannot determine the type of autoloads

In [Godot](godot.md), if you make a [singleton autoload](godot-singletons.md) by autoloading a packed scene that has the script attached, the editor will not be able to determine the type of the autoload.

To workaround this problem, you will need to tell [Godot](godot.md) the type of the autoload.

See: [godotengine/godot#86300](https://github.com/godotengine/godot/issues/86300)

I consider this issue to be a [Godot crime](godot-crimes.md).

## History

![20240313_0348](../entries/20240313_0348.md)
