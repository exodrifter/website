---
title: Godot doesn't export dependencies
created: 2024-10-17T16:42:00Z
aliases:
- "Godot doesn't export dependencies"
tags:
- godot
---

# Godot doesn't export dependencies

As of Godot 4.3, `Export selected scenes (and dependencies)` might make a non-working build because Godot doesn't make a complete dependency graph. The following dependencies will not be included: [^1]
- Localization files referenced by the `Localization > Translations` setting.
- `.gdshaderinc` files that another shader would `#include`.
- Resources that a script will `preload` and store in a `const`.
- Custom classes only referenced by other scripts, such as classes that contain functions (static or not) that are referenced by other scripts and not used in a scene.

These dependencies will also not be included, but I wouldn't expect Godot to handle these: [^1]
- Images embedded in `RichTextLabel` bbcode.
- Resources that are loaded during any execution path, including initialization.

[^1]: [20241016143922](../entries/20241016143922.md)
