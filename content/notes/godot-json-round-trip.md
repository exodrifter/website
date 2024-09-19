---
title: "`JSON` does not round trip"
aliases:
- "`JSON` does not round trip"
tags:
- godot
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

Instead, consider using `store_var` and `get_var` in `FileAccess` (see also: [Arbitrary Code Execution in Godot serialization](godot-serialize-arbitrary-code-execution.md))

## History

![20240617214349](../entries/20240617214349.md)

![20240620003315](../entries/20240620003315.md)
