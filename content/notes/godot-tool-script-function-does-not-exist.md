---
title: "`@tool` script says function does not exist when it does"
aliases:
- "`@tool` script says function does not exist when it does"
tags:
- godot
---

# `@tool` script says function does not exist when it does

In Godot, if you try calling a function on a non-tool script from a tool script, you'll get the error that looks like this:

```
res://test.gd:8 - Invalid call. Nonexistent function 'get_color' in base 'Resource (SwatchRef)'.
```

The error message here is misleading; the function could indeed be defined, but functions will not be loaded unless the script the function is in is _also_ a tool script.

To fix this issue, use the `@tool` annotation on all scripts that contain functions you want to call.

I consider this issue to be a [Godot crime](godot-crimes.md).

# History

- [202312120058](../entries/202312120058.md)
