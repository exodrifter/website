---
title: Wrap mouse cursor in Godot
created: 2024-10-29T00:17:46Z
modified: 2024-11-11T02:48:22Z
aliases:
- Wrap mouse cursor in Godot
tags:
- godot
---

# Wrap mouse cursor in Godot

Sometimes you might want to wrap the mouse cursor within the bounds of the window in Godot, similar to what Blender does when you move the mouse near the bounds of the window. [^1]

To do this, we need to detect if the mouse is close to the window edge by some arbitrary margin. We have to use a margin because if the window is maximized when the mouse hits the edge of the screen, the operating system will not report mouse movement that would move the mouse past the bounds of the window since that would also move the cursor off-screen. [^1]

Here's how you would use `DisplayServer` to warp the mouse within the bounds of the window: [^2]

```gdscript
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		handle_input_mouse_motion(event as InputEventMouseMotion)

func handle_input_mouse_motion(event: InputEventMouseMotion) -> void:
	var window := Rect2i(
		DisplayServer.window_get_position(),
		DisplayServer.window_get_size()
	)
	var new_position := DisplayServer.mouse_get_position()

	const margin := 10
	var warp := false
	if new_position.x < window.position.x + margin:
		warp = true
		new_position.x += window.size.x - (margin * 2)
	elif new_position.x > window.end.x - margin:
		warp = true
		new_position.x -= window.size.x - (margin * 2)
	elif new_position.y < window.position.y + margin:
		warp = true
		new_position.y += window.size.y - (margin * 2)
	elif new_position.y > window.end.y - margin:
		warp = true
		new_position.y -= window.size.y - (margin * 2)
	if warp:
		DisplayServer.warp_mouse(new_position - window.position)
		just_warped = true
```

However, this code will not work under Wayland due to unresolved issues with `warp_mouse` in Godot Engine. [^3]

[^1]: [20241029000745](../entries/20241029000745.md)
[^2]: [20241031203718](../entries/20241031203718.md)
[^3]: [20241111024109](../entries/20241111024109.md)
