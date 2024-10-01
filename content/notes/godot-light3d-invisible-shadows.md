---
title: Cast shadows with invisible geometry
created: 2024-10-01T22:51:50Z
aliases:
- Cast shadows with invisible geometry
tags:
- godot
---

# Cast shadows with invisible geometry

To cast shadows with an invisible geometry, you can use a `MeshInstance3D` with the `cast_shadow` property set to `SHADOW_CASTING_SETTING_SHADOWS_ONLY`. [^1]

Things that won't work:
- A mesh that has a transparent material assigned to it, as the shadow won't work on transparent meshes. [^1]
- Changing the `VisualInstance3D` of your geometry to be on a different layer; the shadow will ignore the geometry. [^1]
- Changing `light_cull_mask` on the `Light3D`; this only changes what surfaces the light appears on. [^1]

[^1]: [20241001224509](../entries/20241001224509.md)
