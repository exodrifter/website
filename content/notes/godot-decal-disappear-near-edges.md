---
title: Decals disappear near edges
created: 2024-06-19T00:12:54Z
modified: 2025-06-10T05:48:31Z
aliases:
- Decals disappear near edges
tags:
- godot
---

# Decals disappear near edges

The edge of a decal can sometimes disappear when viewed from certain angles in Godot 4.2.2. This may be due to a bug in Godot, tracked by the following issues: [^1]

- [godot/godotengine#81889](https://github.com/godotengine/godot/issues/81889)
- [godot/godotengine#73945](https://github.com/godotengine/godot/issues/73945)

This issue only happens when the scale for the decal is non-uniform, so a workaround is to use a uniform scale for the decal. This is not affected by the size of the decal, so non-uniform sizes work fine. [^2]

# History

[^1]: [20240618194223](../entries/20240618194223.md)
[^2]: [20250610054452](../entries/20250610054452.md)
