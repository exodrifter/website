---
title: Wrap mouse cursor in Godot
created: 2024-10-29T00:17:46Z
aliases:
- Wrap mouse cursor in Godot
tags:
- godot
---

# Wrap mouse cursor in Godot

Sometimes you might want to wrap the mouse cursor within the bounds of the window in Godot, similar to what Blender does when you move the mouse near the bounds of the window. [^1]

To do this, we need to detect if the mouse is close to the window edge by some arbitrary margin. We have to use a margin because if the window is maximized when the mouse hits the edge of the screen, the operating system will not report mouse movement that would move the mouse past the bounds of the window since that would also move the cursor off-screen. [^1]

When the mouse is within the bounds, we can warp the mouse. However, the mouse position in Godot is in the viewport's coordinate system, so we have to transform it back to window pixel coordinates in order for the warp to work correctly: [^1]

```gdscript
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		handle_input_mouse_motion(event as InputEventMouseMotion)

func handle_input_mouse_motion(event: InputEventMouseMotion) -> void:
	var window := get_window()
	var xform := get_viewport().get_final_transform()
	var new_position := get_viewport().get_mouse_position() * xform + event.relative

	const margin := 10
	var warp := false
	if new_position.x < margin:
		warp = true
		new_position.x += window.size.x - margin
	if new_position.x > window.size.x - margin:
		warp = true
		new_position.x -= window.size.x - margin
	if new_position.y < margin:
		warp = true
		new_position.y += window.size.y - margin
	if new_position.y > window.size.y - margin:
		warp = true
		new_position.y -= window.size.y - margin

	if warp:
		Input.warp_mouse(new_position)
		just_warped = true
```

[^1]: [20241029240745](../entries/20241029240745.md)
