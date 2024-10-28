---
title: GDShader doesn't pause
created: 2024-05-30T05:53:46Z
modified: 2024-10-28T05:22:13Z
aliases:
- GDShader doesn't pause
tags:
- godot
---

# GDShader doesn't pause

In Godot 4.0, [GDShaders](gdshader.md) don't pause when the tree is paused as the time parameter continues to increase while the game is paused.

Unfortunately, it doesn't appear like the Godot maintainers will fix this for 4.0, because they believe the canonical solution for this should be to add a new global uniform to the project that takes whether or not the tree is paused into account for use in a shader. 

A potential workaround looks like this:

```gdscript
var scaled_time: float
const HOUR: float = 60*60

func _process(delta: float) -> void:
	if not get_tree().paused:
		scaled_time += delta
	while scaled_time > HOUR:
		scaled_time -= HOUR

	RenderingServer.global_shader_parameter_set("SCALED_TIME", scaled_time)
```

 In order to work, a global shader parameter with the name `SCALED_TIME` needs to exist in the project settings and this code needs be added to an autoloaded singleton.

# History

- [20240530054616](../entries/20240530054616.md)
- [202403281816](../entries/202403281816.md)
