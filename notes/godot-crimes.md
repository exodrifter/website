---
aliases:
- Godot crime
- Godot crimes
---

# Godot Crimes

This document contains a list of issues in Godot that I consider code crimes.

## Active Crimes

- [`is_polygon_clockwise` returns the opposite result](godot-geometry2d-clockwise-returns-opposite.md)
- [Lambdas do not capture local variables](godot-gdscript-lambdas-do-not-capture.md)
- [`@tool` script says function does not exist when it does](godot-tool-script-function-does-not-exist.md)
- [`inverse` is an inferior version of `affine_inverse`](godot-transform3d-inverse-inferior-to-affine-inverse.md)
- [Float values NaN and INF are displayed as 0 in debugger and inspector](godot-float-nan-inf-debugger.md)
- [`get_contact_local_position` returns global position](godot-physics-direct-body-state-3d-local-position-is-global.md)

## Addressed Crimes

These crimes have been addressed and are no longer issues in the Godot codebase.

- [Exported variables of inherited scenes are aliased](godot-gdscript-aliased-variables.md), fixed for Godot 4.3
