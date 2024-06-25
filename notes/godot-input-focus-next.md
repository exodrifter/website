---
aliases:
- "How do I focus the next Control?"
---

# How do I focus the next Control?

To focus the next [`Control`](godot-control.md), create a new `InputEventAction` and push it to the current `Viewport`:

```gdscript
var event := InputEventAction.new()
event.action = "ui_focus_next"
event.pressed = true
get_viewport().push_input(event)
```


## History

![20240625_210532](20240625_210532.md)
