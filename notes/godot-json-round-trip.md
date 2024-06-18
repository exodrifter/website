---
aliases:
- "`JSON` does not round trip"
---

# `JSON` does not round trip

 Godot's JSON implementation cannot round trip values. For example, this code...

```gdscript
extends Node

func _ready() -> void:
	var value: Vector2i = Vector2i(3,2)
	var string = JSON.stringify(value)
	print("String: ", string)

	var parsed = JSON.parse_string(string)
	print("Value: ", parsed)
	print("Value is String? ", parsed is String)
	print("Value is Vector2i? ", parsed is Vector2i)
```

...prints this output:

```
String: "(3, 2)"
Value: (3, 2)
Value is String? true
Value is Vector2i? false
```

Instead, consider using `var_to_str` and `str_to_var`.

## History

![20240617_214349](entries/20240617_214349.md)