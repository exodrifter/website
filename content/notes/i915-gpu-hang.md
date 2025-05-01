---
title: i915 GPU Hang
created: 2025-05-01T01:41:10Z
aliases:
- i915 GPU Hang
---

# i915 GPU Hang

I ran into a i915 GPU hang once, that looked like this: [^1]

```
Apr 30 18:14:17 juno kernel: i915 0000:00:02.0: [drm] *ERROR* GT0: GUC: Engine reset failed on 0:0 (rcs0) because 0x00000000
Apr 30 18:14:17 juno kernel: i915 0000:00:02.0: [drm] GPU HANG: ecode 12:1:0020fffe, in ProjectZomboid6 [40069]
```

I am not sure what caused it or how to prevent it from happening again.

[^1]: [20250501012110](../entries/20250501012110.md)
