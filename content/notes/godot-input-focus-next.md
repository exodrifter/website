---
title: "How do I focus the next Control?"
created: 2024-06-25T22:46:38Z
modified: 2024-09-19T04:26:37Z
aliases:
- "How do I focus the next Control?"
tags:
- godot
---

# How do I focus the next Control?

To focus the next `Control`, create a new `InputEventAction` and push it to the current `Viewport`:

```gdscript
var event := InputEventAction.new()
event.action = "ui_focus_next"
event.pressed = true
get_viewport().push_input(event)
```


# History

- [20240625210532](../entries/20240625210532.md)
