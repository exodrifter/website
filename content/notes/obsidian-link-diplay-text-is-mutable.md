---
title: Obsidian link display text is mutable
aliases:
- Obsidian link display text is mutable
tags:
- obsidian
---

# Obsidian link display text is mutable

The display text for internal links in Obsidian is **not** immutable.

Although this doesn't happen every time, Obsidian _can_ change the display text when a file is renamed if the display text is the same as the name of the file and there is no corresponding alias.

For example:
* Create an internal link `[[Foobar|Foobar]]`
* Create the file `Foobar`
* Rename `Foobar` to `bar-baz`
* Observe that the internal link has been updated to `[[bar-baz|bar-baz]]`

This problem could be worked around by adding the display text used in the internal link as an alias for the file **before** renaming the file. In the previous example, this would be done by adding the alias `Foobar` before the file is renamed to `bar-baz`.

# History

- [20240724210051](../entries/20240724210051.md)
- [202306020039](../entries/202306020039.md)
- [202305300005](../entries/202305300005.md)
