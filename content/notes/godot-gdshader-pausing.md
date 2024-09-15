---
title: GDShader doesn't pause
aliases:
- GDShader doesn't pause
---

# GDShader doesn't pause

In [Godot](../notes/godot.md) 4.0, [shaders](godot-gdshader.md) don't pause when the tree is paused as the time parameter continues to increase while the game is paused.

Unfortunately, it doesn't appear like the [Godot](godot.md) maintainers will fix this for 4.0, because they believe the canonical solution for this should be to add a new global uniform to the project that takes whether or not the tree is paused into account for use in a shader. 

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

## History

![20240328_1816](../entries/20240328_1816.md)

![20240530_054616](../entries/20240530_054616.md)