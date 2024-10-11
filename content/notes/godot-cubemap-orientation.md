---
title: Cubemaps are not oriented consistently between rendering pipelines
created: 2024-10-10T21:15:45Z
aliases:
- Cubemaps are not oriented consistently between rendering pipelines
tags:
- godot
---

# Cubemaps are not oriented consistently between rendering pipelines

If you try to create a cube map from images, like the code block below, you might find that images in the cubemap are not oriented correctly: [^1]

```gdscript
@tool
extends Node

const NX = preload("res://prefabs/black_hole/preprocess/nx.png")
const NY = preload("res://prefabs/black_hole/preprocess/ny.png")
const NZ = preload("res://prefabs/black_hole/preprocess/nz.png")
const PX = preload("res://prefabs/black_hole/preprocess/px.png")
const PY = preload("res://prefabs/black_hole/preprocess/py.png")
const PZ = preload("res://prefabs/black_hole/preprocess/pz.png")

@export var preprocess: bool = false
@export var cubemap: Cubemap

func _process(_delta: float) -> void:
	if preprocess:
		preprocess = false

		cubemap = Cubemap.new()
		cubemap.create_from_images([
			PZ.get_image(),
			NZ.get_image(),
			NX.get_image(),
			PX.get_image(),
			PY.get_image(),
			NY.get_image()
		])
```

You might run into this problem because cubemaps do not render the same between Compatability (which uses OpenGL) and the Forward+ (which uses Vulkan) renderers. For more information, see [godotengine/godot#85440](https://github.com/godotengine/godot/issues/85440). [^1]

[^1]: [202404182259](../entries/202404182259.md)
