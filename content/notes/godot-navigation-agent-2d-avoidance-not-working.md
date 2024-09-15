---
title: "My `NavigationAgent2D` is not avoiding other agents"
aliases:
- "My `NavigationAgent2D` is not avoiding other agents"
---

# My `NavigationAgent2D` is not avoiding other agents

> My [`NavigationAgent2D`](godot-navigation-agent-2d.md) is not avoiding other agents even though `avoidance_enabled` is set to `true` and I've adjusted the `radius` and `max_speed` values accordingly.

In order to use avoidance, it's not enough to enable the setting. You also need to write the code to do the following:
* Connect [`NavigationAgent2D`](godot-navigation-agent-2d.md)'s `velocity_computed` signal
* Pass the desired velocity during `_physics_process()` step to [`NavigationAgent2D`](godot-navigation-agent-2d.md)'s `set_velocity()`
* Finally, use the velocity passed by the `velocity_computed` signal to actually do the movement for that physics frame.

# History

![20230531_0209](../entries/20230531_0209.md)
![20230531_0218](../entries/20230531_0218.md)
![20230531_0226](../entries/20230531_0226.md)
![20230531_0236](../entries/20230531_0236.md)
