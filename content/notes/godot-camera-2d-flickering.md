---
title: "My `Camera2D` is flickering"
aliases:
- "My `Camera2D` is flickering"
---

# My `Camera2D` is flickering

> My camera is rendering the incorrect position for a frame even though I've put in a debugging statement showing that the position is correct!

[[godot-camera-2d|`Camera2D`]] contains a mutable state which needs to be communicated to a `Viewport` in the rendering server. This problem can be fixed by calling `align()` to force the state in the rendering server to be synced.

# History

![20230516_0150](../entries/20230516_0150.md)
![20230516_0203](../entries/20230516_0203.md)
![20230517_0041](../entries/20230517_0041.md)
![20230517_0051](../entries/20230517_0051.md)
![20230517_0056](../entries/20230517_0056.md)
![20230517_0121](../entries/20230517_0121.md)
![20230517_0218](../entries/20230517_0218.md)
![20230517_0315](../entries/20230517_0315.md)
