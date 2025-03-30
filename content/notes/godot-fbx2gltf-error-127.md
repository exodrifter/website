---
title: "FBX conversion to glTF failed with error: 127"
created: 2025-03-30T19:19:29Z
aliases:
- "FBX conversion to glTF failed with error: 127"
tags:
- godot
---

# FBX conversion to glTF failed with error: 127

In Godot 4.3, `FBX2glTF` was replaced with `ubx` and is no longer maintained. [^1]

However, the `FBX2glTF` import option is still available in Godot and any existing FBX assets might still be configured to use the `FBX2glTF` importer. This can result in the following error if `FBX2glTF` is not installed: [^2]

```
  ERROR: modules/fbx/editor/editor_scene_importer_fbx2gltf.cpp:92 - FBX conversion to glTF failed with error: 127.
```

To fix this issue in Godot 4.3 onwards, change the import setting `fbx/importer` to `ufbx`. Or, you can install `FBX2glTF` again but this isn't recommended since it's no longer maintained. [^2]

[^1]: [20250330190929](../entries/20250330190929.md)
[^2]: [20250330192223](../entries/20250330192223.md)
