---
aliases:
- Godot GUI lags on tree change
---

# Godot GUI lags on tree change

In [Godot](godot.md) 4.0, having a large tree of `Control` nodes can result in lag whenever new control nodes are added or removed from the tree. I'm guessing these issues are a result of Godot's GUI layout functions taking a long time. These issues can be addressed by:

- Reusing controls when possible instead of creating new ones.
	- It appears to be cheaper to have two `RichTextLabel`s that you toggle the visibility on than to change the text on it, so don't try to reuse the same `RichTextLabel` for text that changes. ([20240604_190518](../entries/20240604_190518.md))
- Use less controls, especially containers, whenever possible.

## History

![20240530_172341](../entries/20240530_172341.md)

![20240604_190518](../entries/20240604_190518.md)
