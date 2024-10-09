---
title: "`is_polygon_clockwise` returns the opposite result"
created: 2024-07-03T19:10:44Z
modified: 2024-09-19T04:56:37Z
aliases:
- "`is_polygon_clockwise` returns the opposite result"
tags:
- godot
---

# `is_polygon_clockwise` returns the opposite result

In Godot 4.2.2, the implementation of [`is_polygon_clockwise`](https://docs.godotengine.org/en/4.2/classes/class_geometry2d.html#class-geometry2d-method-is-polygon-clockwise) in `Geometry2D` treats the vertices as being in a space where the y-axis is positive in the up direction. This causes it to return the incorrect value for 2D games, since Godot treats the y-axis as being positive in the down direction.

I opened [godotengine/godot#89635](https://github.com/godotengine/godot/pull/89635) to address this issue in the API.

I consider this issue to be a [Godot crime](godot-crimes.md).

# History

- [20240703190344](../entries/20240703190344.md)
- [First Godot PR](../blog/20230729232005.md)
- [202307280735](../entries/202307280735.md)
