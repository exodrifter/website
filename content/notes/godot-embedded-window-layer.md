---
title: Godot embedded windows layer
created: 2025-02-10T19:16:01Z
aliases:
- Godot embedded windows layer
tags:
- godot
---

# Godot embedded windows layer

When adding embedded windows, you might find that they always render over all of the other controls. This is because embedded windows are placed on layer `1024`. [^1]

To render controls over the embedded window, you need to add those controls to a `CanvasLayer` on layer `1025`. Since you cannot set the `CanvasLayer` to this value in the inspector, you will have to write a script that sets the layer. [^1]

[^1]: [20250210191157](../entries/20250210191157.md)
