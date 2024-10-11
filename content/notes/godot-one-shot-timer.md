---
title: How do I create a one-shot timer?
created: 2023-05-29T19:10Z
aliases:
- How do I create a one-shot timer?
tags:
- godot
---

# How to I create a one-shot timer?

> [!question]
> How do I create a timer that doesn't repeat so I can wait a certain amount of time exactly once without creating a `Timer` node?

Use `SceneTree`'s `create_timer` method and use the `timeout` property of the newly-created `SceneTreeTimer`.

```gdscript
func some_function():
    print("Timer started.")
    await get_tree().create_timer(1.0).timeout
    print("Timer ended.")
```

# History

- [202305291910](../entries/202305291910.md)
