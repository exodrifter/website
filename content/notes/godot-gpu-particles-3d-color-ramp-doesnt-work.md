---
title: "`GPUParticles3D.color_ramp` doesn't work"
created: 2024-11-06T06:28:02Z
modified: 2024-11-10T05:14:11Z
aliases:
- "`GPUParticles3D.color_ramp` doesn't work"
tags:
- godot
---

# `GPUParticles3D.color_ramp` doesn't work

As of Godot 4.3.stable, `color_ramp` will not have an effect unless the materials in the draw pass are configured correctly: [^1]
- For `BaseMaterial3D`, `BaseMaterial3D.vertex_color_use_as_albedo` must be true.
- For `ShaderMaterial`, `ALBEDO *= COLOR.rgb`; must be inserted in the shader's `fragment()` function.

[^1]: [20241106062026](entries/20241106062026.md)
