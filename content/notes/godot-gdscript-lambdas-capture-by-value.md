---
title: Lambdas capture local variables by value
aliases:
- Lambdas capture local variables by value
tags:
- godot
---

# Lambdas capture local variables by value

In Godot, GDScript lambdas only copy the _value_ of each variable it captures (by design; see [godotengine/godot#69014](https://github.com/godotengine/godot/issues/69014#issuecomment-1324017859)). However, since the value of a `Variant` is itself a reference, you can use a `Variant` to get around this problem if you want the lambda to mutate a capture.

For example, this does not work:

```gdscript
func foobar():
	var stop = false
	var stop_callback = func():
			stop = true
	some_signal.connect(stop_callback)

	await get_tree().create_timer(10).timeout

	print(stop) # Always false
```

But this does:

```gdscript
func foobar():
	var stop = { "value": false }
	var stop_callback = func():
			stop["value"] = true
	some_signal.connect(stop_callback)

	await get_tree().create_timer(10).timeout

	print(stop["value"]) # Either true or false
```

I used to consider this a [Godot crime](godot-crimes.md), but I have since changed my mind.

# History

- [20240704072433](../entries/20240704072433.md)
- [202310030153](../entries/202310030153.md)
