---
title: Godot crimes
created: 2024-06-29T08:10:42Z
modified: 2024-10-11T02:35:15Z
aliases:
- Godot crime
- Godot crimes
tags:
- godot
---

# Godot Crimes

This document contains a list of issues in Godot that I consider code crimes.

## Active Crimes

These crimes have not been addressed and are still issues in the Godot codebase.

- [`is_polygon_clockwise` returns the opposite result](godot-geometry2d-clockwise-returns-opposite.md)
- [`@tool` script says function does not exist when it does](godot-tool-script-function-does-not-exist.md)
- [`inverse` is an inferior version of `affine_inverse`](godot-transform3d-inverse-inferior-to-affine-inverse.md)
- [Godot cannot determine the type of autoloads](godot-singletons-unknown-type.md)
- [Float values NaN and INF are displayed as 0 in debugger and inspector](godot-float-nan-inf-debugger.md)
- [`get_contact_local_position` returns global position](godot-physics-direct-body-state-3d-local-position-is-global.md)
- [Cubemaps are not oriented consistently between rendering pipelines](godot-cubemap-orientation.md)
- [Godot always runs scripts in deserialized resources](godot-runs-scripts-in-resources.md)

## Solved Crimes

These crimes have been addressed and are no longer issues in the Godot codebase.

- [Exported variables of inherited scenes are aliased](godot-gdscript-aliased-variables.md), fixed for Godot 4.3

## Pardoned Crimes

I no longer consider the following items as crimes.

- [Lambdas do not capture local variables](godot-gdscript-lambdas-capture-by-value.md); Godot actually passes everything by value to the closure and it just so happens that the value of `Variant` variables is itself a reference. I think this design is less confusing than any alternative I can think of.
