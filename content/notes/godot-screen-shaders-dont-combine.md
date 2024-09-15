---
aliases:
- Godot screen shaders don't combine
---

# Godot screen shaders don't combine

Only the last [screen shader](godot-gdshader.md) in the tree will be used if multiple screen shaders are in the tree. In order to have multiple screen shaders overlaid on top of each other, a [`CanvasLayer`](godot-canvas-layer.md) needs to be used.

For each [screen shader](godot-gdshader.md), put it under a parent of type [`CanvasLayer`](godot-canvas-layer.md), and set the `layer` property of the `CanvasLayer` to the correct number such that the effects are in the desired order.

## History

![20240604_154022](../entries/20240604_154022.md)
