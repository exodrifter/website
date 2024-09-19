---
title: Godot cannot determine the type of autoloads
aliases:
- Godot cannot determine the type of autoloads
tags:
- godot
---

# Godot cannot determine the type of autoloads

In Godot, if you make a singleton autoload by autoloading a packed scene that has the script attached, the editor will not be able to determine the type of the autoload.

To workaround this problem, you will need to tell Godot the type of the autoload.

See: [godotengine/godot#86300](https://github.com/godotengine/godot/issues/86300)

I consider this issue to be a [Godot crime](godot-crimes.md).

# History

- [202403130348](../entries/202403130348.md)
