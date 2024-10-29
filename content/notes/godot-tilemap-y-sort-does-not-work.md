---
title: "Enabling Y-Sort on my `TileMap` does not work"
created: 2023-07-07T20:06Z
aliases:
- "Enabling Y-Sort on my `TileMap` does not work"
tags:
- godot
---

# Enabling Y-Sort on my `TileMap` does not work

> [!question]
> I've enabled the Y-sort option on my tilemap, but it doesn't seem to work; it's only using the y-position of the map instead of the y-position of each tile.

Each individual `TileMap` layer has its own Y-sort option that _also_ needs to be checked in order for the Y-sort to work properly. [^1]

# History

[^1]: [202307072006](../entries/202307072006.md)
