---
title: "Godot `Window` does not lose focus"
created: 2025-02-06T19:28:51Z
aliases:
- "Godot `Window` does not lose focus"
tags:
- godot
---

# Godot `Window` does not lose focus

For some reason, `Window`s do not always lose focus when other windows are focused. There isn't a function to explicitly drop focus, so to work around this problem you can focus of all of the other windows before grabbing the focus of the window you want to focus. For example: [^1]

```gdscript
func _on_notes_button_pressed() -> void:
	notes_ui.visible = not notes_ui.visible
	if notes_ui.visible:
		focus_window(notes_ui)

func _on_map_button_pressed() -> void:
	map_ui.visible = not map_ui.visible
	if map_ui.visible:
		focus_window(map_ui)

func focus_window(window_to_focus: Window) -> void:
	# For some reason, focus isn't dropped when we focus the new window and
	# there's no function to explicitly drop focus. So, to work around this
	# we focus the window we want to unfocus right before we focus the
	# window we want to focus
	for window: Window in get_viewport().get_embedded_subwindows():
		if window != window_to_focus:
			window.grab_focus()

	window_to_focus.grab_focus()
```

[^1]: [20250206191936](../entries/20250206191936.md)
