---
title: "`JSON` does not round trip"
created: 2024-06-18T00:37:16Z
modified: 2024-10-28T04:40:46Z
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

Instead of storing data in JSON, consider using `store_var` and `get_var` in `FileAccess` instead (see: [Arbitrary Code Execution in Godot serialization](godot-serialize-arbitrary-code-execution.md)).

# History

- [20240620003315](../entries/20240620003315.md)
- [20240617214349](../entries/20240617214349.md)
