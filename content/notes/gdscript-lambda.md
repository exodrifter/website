---
title: GDScript Lambdas
created: 2024-10-29T05:52:43Z
aliases:
- GDScript Lambdas
tags:
- gdscript
---

# GDScript Lambdas

[GDScript](../tags/gdscript.md) has support for lambas: [^1]

```gdscript
func make_filter(max: int) -> Callable:
	var l := func filter(val: int):
		return val < max
	return l
```

[^1]: [202307281942](../entries/202307281942.md)
