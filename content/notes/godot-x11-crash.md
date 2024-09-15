---
title: Godot often crashes at random on X11
aliases:
- Godot often crashes at random on X11
---

# Godot often crashes at random on X11

The Godot editor or Godot games often crash at random on Linux due to an open X11 bug:

> [Rémi Verschelde @akien](https://gitlab.freedesktop.org/xorg/lib/libx11/-/issues/199#note_2393821):
>
> Hello, Godot maintainer here. We still get regular bug reports about this, and this doesn't seem to be fixed in latest libX11 1.8.9.
>
> Every version since 1.8.3 seems to have exposed new random threading related crashes.

This issue can be worked around by downgrading `libx11` to version `1.8.2-1`.

## History

![20240805_225007](../entries/20240805_225007.md)