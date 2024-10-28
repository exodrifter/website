---
title: Fonts are missing glyphs on some systems
created: 2024-06-11T02:37:19Z
modified: 2024-10-28T04:58:26Z
aliases:
- Fonts are missing glyphs on some systems
tags:
- godot
---

# Fonts are missing glyphs on some systems

 By default, [`Font`](godot-font.md) resources in Godot are imported with a setting that allows the use of system fonts as a fallback turned on by default. However, not everyone's machine might have a system font that has the glyph we want to render.

Turning this setting off will ensure that the font will be rendered the same regardless of whose system it is running on.

# History

- [20240612004207](../entries/20240612004207.md)
