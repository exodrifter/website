---
title: Quaternion rotation is frame dependent
created: 2025-08-06T00:10:37-07:00
aliases:
- Quaternion rotation is frame dependent
- Godot quaternion rotation is frame dependent
tags:
- godot
---

# Quaternion rotation is frame dependent

This code is frame dependent: [^1]

```gdscript
extends Node3D

var spin := Quaternion.from_euler(Vector3(1, 1, 1))

func _process(delta: float) -> void:
	quaternion *= spin * delta
```

This is because `spin` is a `Quaternion`, and multiplying it by delta only does a component-wise multiplication. This results in frame-dependent rotation, where the speed of the rotation is different depending on how high the framerate is. In order to scale the rotation, use `slerp`. For example: [^2]

```gdscript
func _process(delta: float) -> void:
	quaternion *= Quaternion.IDENTITY.slerp(spin, delta)
```

[^1]: [20250731000658](../entries/20250731000658.md)
[^2]: [20250806070153](../entries/20250806070153.md)
