---
title: Blender files are invalid or corrupt
aliases:
- Blender files are invalid or corrupt
tags:
- godot
---

# Blender files are invalid or corrupt

In order for Godot to import `.blend` files, the `filesystem/import/blender/blender3_path` editor setting must be set to _the folder containing the Blender executable_. For example, if Blender is installed at `/bin/blender`, set the value to `/bin`.

Otherwise, the blender scene and any scenes containing blender scenes can be considered invalid or corrupt by Godot.

## History

![20240616212133](../entries/20240616212133.md)
