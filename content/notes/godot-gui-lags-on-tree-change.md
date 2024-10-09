---
title: GUI lags on tree change
created: 2024-05-30T17:37:40Z
modified: 2024-09-19T04:26:37Z
aliases:
- GUI lags on tree change
tags:
- godot
---

# GUI lags on tree change

In Godot 4.0, having a large tree of `Control` nodes can result in lag whenever new control nodes are added or removed from the tree. I'm guessing these issues are a result of Godot's GUI layout functions taking a long time. These issues can be addressed by:

- Reusing controls when possible instead of creating new ones.
	- It appears to be cheaper to have two `RichTextLabel`s that you toggle the visibility on than to change the text on it, so don't try to reuse the same `RichTextLabel` for text that changes. ([20240604190518](../entries/20240604190518.md))
- Use less controls, especially containers, whenever possible.

## Other problems

The GUI can lag for a number of other reasons:
- [`RichTextLabel` lags on first draw](godot-rich-text-label-first-draw-lag.md)

# History

- [20240607184945](../entries/20240607184945.md)
- [20240604190518](../entries/20240604190518.md)
- [20240530172341](../entries/20240530172341.md)
