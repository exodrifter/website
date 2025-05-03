---
title: Godot doesn't export dependencies
created: 2024-10-17T16:42:00Z
modified: 2024-10-28T05:21:06Z
aliases:
- "Godot doesn't export dependencies"
tags:
- godot
- gdshader
---

# Godot doesn't export dependencies

As of Godot 4.3, `Export selected scenes (and dependencies)` might make a non-working build because Godot doesn't make a complete dependency graph. The following dependencies will not be included: [^1]
- Localization files referenced by the `Localization > Translations` setting.
- `.gdshaderinc` files that another [GDShader](../tags/gdshader.md) would `#include`.
- Resources that a script will `preload` and store in a `const`.
- Custom classes only referenced by other scripts, such as classes that contain functions (static or not) that are referenced by other scripts and not used in a scene.
- Bus layout files referenced by the `audio/buses/default_bus_layout` setting [^2]

These dependencies will also not be included, but I wouldn't expect Godot to handle these: [^1]
- Images embedded in `RichTextLabel` bbcode.
- Resources that are loaded during any execution path, including initialization.
- `FileAccess` does not work for `res://` paths; use `ResourceLoader` instead. I'm guessing this is because when the game is built, the game resources are now in the `.pck` file and there is no file system to navigate. [^2]

[^1]: [20241016143922](../entries/20241016143922.md)
[^2]: [20241018194335](../entries/20241018194335.md)
