---
title: "`Area2D` calls the `body_entered` signal multiple times"
created: 2024-07-04T05:02:06Z
modified: 2024-09-19T04:26:37Z
aliases:
- "`Area2D` calls the `body_entered` signal multiple times"
tags:
- godot
---

# `Area2D` calls the `body_entered` signal multiple times

In Godot, when calling `reparent` on a `Node2D`, this will cause the `Area2D` to call `body_exited` immediately followed by `body_entered`. For example, this pseudocode...

```gdscript
func _on_body_entered(body):
	print("entered")
	teleport()

func _on_body_exited(body):
	print("exited")

func teleport():
	print("reparent")
	self.reparent( ... )
	print("global position")
	self.global_position = ...
```

...results in the following output:

```
entered
reparent
exited
entered
global position
reparent
global position
exited
```

# History

- [202308120434](../entries/202308120434.md)
