---
title: Godot always runs scripts in deserialized resources
created: 2024-10-10T21:42:27Z
aliases:
- Godot always runs scripts in deserialized resources
tags:
- godot
---

# Godot always runs scripts in deserialized resources

In Godot, any resource that is deserialized by the engine will _also_ be executed, regardless of if that deserialized data is actually used, effectively creating an arbitrary code execution vulnerability. For example, consider the following configuration file: [^1]

```
[Foobar] foobar=Object(Resource,"script":Object(GDScript,"resource_local_to_scene":false,"resource_name":"","script/source":"extends Resource func _init(): print(\"Hello, world!\")"))
```

With the `ConfigFile` API, loading this configuration file will also print `Hello, world!` to the console even if we don't try to read the `foobar` value. [^1]

This issue may be addressed in the future by [godotengine/godot-proposals#4925](https://github.com/godotengine/godot-proposals/issues/4925). [^1]

[^1]: [202403262131](../entries/202403262131.md)
