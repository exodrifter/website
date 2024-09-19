---
title: "`ERR_FILE_BAD_PATH` when importing files"
aliases:
- "`ERR_FILE_BAD_PATH` when importing files"
tags:
- godot
---

# `ERR_FILE_BAD_PATH` when importing files

When importing files in Godot, it is possible to get this error in the console:

```
editor/import/resource_importer_scene.cpp:2405 - Condition "!save_path.is_empty() && !DirAccess::exists(save_path.get_base_dir())" is true. Returning: ERR_FILE_BAD_PATH
  Error importing 'res://scenes/background/3d_backgrounds/locomotive/locomotive.blend'.
```

This error happens when the `save_to_file/path` value is set to a path which does not exist and it can prevent you from running the game. To resolve it, you can do one of the following:
- Change the `save_to_file/path` value to a valid path.
- Create the path that `save_to_file/path` uses.
- Set the `save_to_file/enabled` value to `false`

However, at least as of Godot 4.2.2, Godot will not let you update these properties in the advanced import settings dialog. You can change them in the dialog, but your changes will be reverted when the dialog is closed. To get around this issue, close Godot and edit the `.import` file for the affected resources directly.

# History

- [20240616174856](../entries/20240616174856.md)
