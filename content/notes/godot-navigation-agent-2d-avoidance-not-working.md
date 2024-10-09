---
title: "My `NavigationAgent2D` is not avoiding other agents"
created: 2024-08-21T04:04:01Z
modified: 2024-09-19T04:26:37Z
aliases:
- "My `NavigationAgent2D` is not avoiding other agents"
tags:
- godot
---

# My `NavigationAgent2D` is not avoiding other agents

> My `NavigationAgent2D` is not avoiding other agents even though `avoidance_enabled` is set to `true` and I've adjusted the `radius` and `max_speed` values accordingly.

In order to use avoidance, it's not enough to enable the setting. You also need to write the code to do the following:
* Connect `NavigationAgent2D`'s `velocity_computed` signal
* Pass the desired velocity during `_physics_process()` step to `NavigationAgent2D`'s `set_velocity()`
* Finally, use the velocity passed by the `velocity_computed` signal to actually do the movement for that physics frame.

# History

- [202305310236](../entries/202305310236.md)
- [202305310226](../entries/202305310226.md)
- [202305310218](../entries/202305310218.md)
- [202305310209](../entries/202305310209.md)
