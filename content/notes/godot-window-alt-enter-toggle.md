---
title: Godot doesn't support Alt+Enter toggle
created: 2025-05-20T19:17:10Z
aliases:
- Godot doesn't support Alt+Enter toggle
tags:
- godot
---

# Godot doesn't support Alt+Enter toggle

`Alt+Enter` is a common shortcut convention used by video games which Godot does not implement as of Godot 4.X ([see godotengine/godot-proposals#1983](https://github.com/godotengine/godot-proposals/issues/1983)). To get around this, you need to implement the toggle yourself. For example, you can add a global autoload `GlobalShortcut` with the following script: [^1]

```gdscript
extends Node

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event: InputEventKey = event
		handle_key_event(key_event)

static func handle_key_event(event: InputEventKey) -> void:
	if not event.pressed:
		return

	if event.alt_pressed and event.physical_keycode == KEY_ENTER:
		toggle_fullscreen()

static func toggle_fullscreen() -> void:
	var mode := DisplayServer.window_get_mode()
	match mode:
		DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		DisplayServer.WINDOW_MODE_MINIMIZED:
			pass
		DisplayServer.WINDOW_MODE_MAXIMIZED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
```

[^1]: [20250520183426](20250520183426.md)
