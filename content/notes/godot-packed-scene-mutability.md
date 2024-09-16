---
title: "`PackedScene` mutability"
aliases:
- "`PackedScene` mutability"
tags:
- godot
---

# `PackedScene` mutability

When an imported scene is duplicated, the exported values on the root of the `PackedScene` are also copied from the original instance. This might be an issue if you were using an exported value as an internal configuration value.

> For example, you may want to store references to `NodePath` values to internal nodes and change these values based on what whatever scene you're making. However, when this script is used at the root of an imported scene and that scene is duplicated, these references will point to internal nodes in the original scene instead of the internal nodes in the duplicated scene.

Instead of using exported fields to store internal information, have the root script determine the information somehow (for example, by storing the information at a special path internally). Try to only export fields you want the user to configure when it is instantiated.

## History

![20240604_191544](../entries/20240604_191544.md)
