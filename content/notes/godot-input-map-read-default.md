---
title: Read the default input mapping
created: 2025-01-08T23:52:26Z
aliases:
- Read the default input mapping
tags:
- godot
---

# Read the default input mapping

In Godot, you can read the default input configuration without loading it into the `InputMap` by using the `ProjectSettings` API. [^1]

Example:

```gdscript
var input_map: Dictionary = ProjectSettings.get_setting("input/ui_confirm", {})
```

[^1]: [20250108235042](../entries/20250108235042.md)
