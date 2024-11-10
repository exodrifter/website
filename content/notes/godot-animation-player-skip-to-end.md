---
title: "Skip to the end of an `Animation` in `AnimationPlayer`"
created: 2024-11-10T00:26:35Z
aliases:
  - "Skip to the end of an `Animation` in `AnimationPlayer`"
tags:
  - godot
---

# Skip to the end of an `Animation` in `AnimationPlayer`

As of Godot 4.3.stable, to skip to the end of an `Animation` in `AnimationPlayer` without triggering any frames in between, you can call the `play` method with `custom_speed = 0.0` and `from_end = true`. [^1]

```gdscript
play(animation_name, -1, 0, true)
```

[^1]: [20241110001500](../entries/20241110001500.md)
