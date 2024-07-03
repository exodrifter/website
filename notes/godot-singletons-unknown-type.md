---
aliases:
- Godot cannot determine the type of autoloads
---

# Godot cannot determine the type of autoloads

If you make a [singleton autoload](godot-singletons.md) by autoloading a packed scene that has the script attached, the editor will not be able to determine the type of the autoload.

To workaround this problem, you will need to tell Godot the type of the autoload.

See: [godotengine/godot#86300](https://github.com/godotengine/godot/issues/86300)

## History

![20240313_0348](../entries/20240313_0348.md)
