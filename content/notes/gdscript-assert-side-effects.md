---
title: "`assert` does not run side effects"
created: 2025-05-03T18:32:11Z
aliases:
- "`assert` does not run side effects"
tags:
- gdscript
---

# `assert` does not run side effects

In Godot, `assert` statements *and the code inside of them* do **not** get executed in debug builds. This means that any expression provided as the condition for the `assert` statement will not run in release builds. If this conditional expression contains a side-effect, then the release build will behave differently from the debug build. [^1]

[^1]: [20250503182450](../entries/20250503182450.md)
