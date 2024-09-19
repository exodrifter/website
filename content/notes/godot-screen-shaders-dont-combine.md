---
title: Screen shaders don't combine
aliases:
- Screen shaders don't combine
tags:
- godot
---

# Screen shaders don't combine

Only the last screen shader in the tree will be used if multiple screen shaders are in the tree. In order to have multiple screen shaders overlaid on top of each other, a `CanvasLayer` needs to be used.

For each screen shader, put it under a parent of type `CanvasLayer`, and set the `layer` property of the `CanvasLayer` to the correct number such that the effects are in the desired order.

## History

![20240604154022](../entries/20240604154022.md)
