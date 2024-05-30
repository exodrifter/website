---
aliases:
- Godot GUI lags on tree change
---

# Godot GUI lags on tree change

In [Godot](godot.md) 4.0, having a large tree of `Control` nodes can result in lag whenever new control nodes are added or removed from the tree. I'm guessing these issues are a result of Godot's GUI layout functions taking a long time. These issues can be addressed by:

- Reusing controls when possible instead of creating new ones. It appears to be cheaper to change the text than to add a new control that has alternate text on it due to the reduced number of things that need to be considered during the layout function.
- Use less controls, especially containers, whenever possible.

## History

![20240530_172341](../entries/20240530_172341.md)
