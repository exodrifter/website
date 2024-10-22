---
title: Godot orphan leaks
created: 2024-10-22T02:28:04Z
aliases:
- Godot orphan leaks
tags:
- godot
---

# Godot orphan leaks

In Godot, `Node` is not `RefCounted`. This means that nodes will not be freed automatically when they are no longer referenced. You'll have to manage them explicitly. [^1]

Whenever you use `duplicate`, `instantiate`, or `remove_child`, Godot keeps that node loaded in memory even when the script which is holding a reference to the node is deleted. Godot *only* frees nodes when `queue_free` or `free` is called on a node or one of its parents. [^1]

You can use `print_orphan_nodes()` to find out what is being leaked and there is also an orphan count monitor in the Godot debugger. [^1]

[^1]: [20241021200223](../entries/20241021200223.md)
