---
title: "My `Camera2D` is flickering"
aliases:
- "My `Camera2D` is flickering"
tags:
- godot
---

# My `Camera2D` is flickering

> My camera is rendering the incorrect position for a frame even though I've put in a debugging statement showing that the position is correct!

`Camera2D` contains a mutable state which needs to be communicated to a `Viewport` in the rendering server. This problem can be fixed by calling `align()` to force the state in the rendering server to be synced.

# History

![202305160150](../entries/202305160150.md)
![202305160203](../entries/202305160203.md)
![202305170041](../entries/202305170041.md)
![202305170051](../entries/202305170051.md)
![202305170056](../entries/202305170056.md)
![202305170121](../entries/202305170121.md)
![202305170218](../entries/202305170218.md)
![202305170315](../entries/202305170315.md)
