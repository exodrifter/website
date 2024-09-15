---
aliases:
- "`@tool` script says function does not exist when it does"
---

# `@tool` script says function does not exist when it does

In [Godot](godot.md), if you try calling a function on a non-tool script from a [tool script](godot-tool-script.md), you'll get the error that looks like this:

```
res://test.gd:8 - Invalid call. Nonexistent function 'get_color' in base 'Resource (SwatchRef)'.
```

The error message here is misleading; the function could indeed be defined, but functions will not be loaded unless the script the function is in is _also_ a tool script.

To fix this issue, use the `@tool` annotation on all scripts that contain functions you want to call.

I consider this issue to be a [Godot crime](godot-crimes.md).

## History

![20231212_0058](../entries/20231212_0058.md)
