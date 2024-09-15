---
title: "`Area2D` calls the `body_entered` signal multiple times"
aliases:
- "`Area2D` calls the `body_entered` signal multiple times"
---

# `Area2D` calls the `body_entered` signal multiple times

In [Godot](godot.md), when calling `reparent` on a `Node2D`, this will cause the [`Area2D`](godot-area2d.md) to call `body_exited` immediately followed by `body_entered`. For example, this pseudocode...

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

## History

![20230812_0434](../entries/20230812_0434.md)
