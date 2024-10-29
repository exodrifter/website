---
title: "My `NavigationAgent2D` fails to navigate after teleporting"
created: 2023-07-27T19:45Z
aliases:
- "My `NavigationAgent2D` fails to navigate after teleporting"
tags:
- godot
---

# My `NavigationAgent2D` fails to navigate after teleporting

> [!question]
> The `NavigationAgent2D` is no longer generating a valid, correct path to travel on after teleporting and it has not reached its destination.

Not sure why this is a problem, but the following workaround seems to work: [^1]

```gdscript
func teleport(door: Door) -> void:
	# Change the position of the entity...

	# Try repathing after teleporting
	navigation_agent.target_position = target.global_position
```

[^1]: [202307271945](../entries/202307271945.md)
