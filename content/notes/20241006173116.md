---
title: The top of the code sticks around as a split view
created: 2024-10-06T17:31:16Z
aliases:
- The top of the code sticks around as a split view
tags:
- vs-code
---

# The top of the code sticks around as a split view

While scrolling through a file in the editor, you may notice that the first few lines of the file are stuck to the top of the screen in a split view. This is a feature in VS Code called "Sticky Scroll". To disable this behavior, do one of the following: [^1]

- Right click the sticky scroll split view to get a context menu that lets you turn it off.
- Run `View: Toggle Sticky Scroll` in the command palette.
- Run `Preferences: Open User Settings (JSON)` and add `"editor.stickyScroll.enabled": false` to your configuration

[^1]: [20241006172540](../entries/20241006172540.md)
