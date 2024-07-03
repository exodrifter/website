---
aliases:
- Lambdas do not capture local variables
---

# Lambdas do not capture local variables

Lambdas do not capture local variables as they only copy the _value_ of each variable (by design; see [godotengine/godot#69014](https://github.com/godotengine/godot/issues/69014#issuecomment-1324017859)). However, since `Variant` is passed by reference, you can use a `Variant` to get around this problem.

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

## History

![20231003_0153](../entries/20231003_0153.md)
