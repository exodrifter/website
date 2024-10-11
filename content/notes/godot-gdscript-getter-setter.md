---
title: How do I create a getter and setter for variables?
created: 2023-05-29T21:19Z
aliases:
- How do I create a getter and setter for variables?
tags:
- godot
---

# How do I create a getter and setter for variables?

> [!question]
> How do I create getters and setters for my variables in GDScript so that I can ensure that some code always runs when the value is gotten or set?

```gdscript
@export var foobar: Array = [] :
    get:
        return foobar
    set(value):
        foobar = value
```

# History

![202305292119](../entries/202305292119.md)
