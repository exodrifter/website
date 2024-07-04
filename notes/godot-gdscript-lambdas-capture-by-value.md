---
aliases:
- Lambdas capture local variables by value
---

# Lambdas capture local variables by value

In [Godot](godot.md), [GDScript](godot-gdscript.md) lambdas only copy the _value_ of each variable it captures (by design; see [godotengine/godot#69014](https://github.com/godotengine/godot/issues/69014#issuecomment-1324017859)). However, since the value of a `Variant` is itself a reference, you can use a `Variant` to get around this problem if you want the lambda to mutate a capture.

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

## History

![20231003_0153](../entries/20231003_0153.md)

![20240704_072433](../entries/20240704_072433.md)
