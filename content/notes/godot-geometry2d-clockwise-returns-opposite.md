---
title: "`is_polygon_clockwise` returns the opposite result"
aliases:
- "`is_polygon_clockwise` returns the opposite result"
---

# `is_polygon_clockwise` returns the opposite result

In [Godot](notes/godot.md) 4.2.2, the implementation of [`is_polygon_clockwise`](https://docs.godotengine.org/en/4.2/classes/class_geometry2d.html#class-geometry2d-method-is-polygon-clockwise) in [`Geometry2D`](godot-geometry2d.md) treats the vertices as being in a space where the y-axis is positive in the up direction. This causes it to return the incorrect value for 2D games, since Godot treats the y-axis as being positive in the down direction.

I opened [godotengine/godot#89635](https://github.com/godotengine/godot/pull/89635) to address this issue in the API.

I consider this issue to be a [Godot crime](godot-crimes.md).

## History

![20230728_0735](../entries/20230728_0735.md)

![20240703_190344](../entries/20240703_190344.md)
