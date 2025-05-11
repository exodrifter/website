---
title: "Cannot move past `Camera2D` bounds"
created: 2023-05-22T21:04-0500
aliases:
- "Cannot move past `Camera2D` bounds"
tags:
- godot
---

# Cannot move past `Camera2D` bounds

> I cannot seem to move past the bounds of my Camera even though the bounds appear to be calculated correctly and there is obviously more map that I can traverse.

Make sure that the `Camera2D` bounds, which are in global space, and the position you are clamping are both in the same space.

# History

- [202305211926](../entries/202305211926.md)
- [202305230158](../entries/202305230158.md)
- [202305230204](../entries/202305230204.md)
