---
title: Obsidian Internal Link
created: 2023-05-30T00:05Z
modified: 2024-10-11T06:23:39Z
aliases:
- Obsidian Internal Link
- Obsidian Internal Links
tags:
- obsidian
---

# Obsidian Internal Link

Official Documentation: [help.obsidian.md](https://help.obsidian.md/Linking+notes+and+files/Internal+links)

Used to link to another [Obsidian Note](obsidian-note.md) in the same vault; one of the additional syntax options in [Obsidian Flavored Markdown](obsidian-flavored-markdown.md).

# Syntax

There are two ways to make an Obsidian Internal Link: [^2]

* Using the Wikilink format: `[[Three laws of motion]]`
* Using the Markdown format: `[Three laws of motion](Three%20laws%20of%20motion.md)`

You can also link to a specific heading of a note by using `#`. For example: `[[Three laws of motion#Second law]]`.

The display text of an Obsidian Internal Link can be changed in the following ways: [^3]

* Wikilink Format: `[[Three laws of motion|Display Text]]`
* Markdown Format: `[Display Text](Three%20laws%20of%20motion.md)`

When in a table, the pipe character (`|`) used in the Wikilink format will have to be escaped with a backslash (`\`). [^3]

# How to use

Always add display text for links. This gives a higher chance of allowing all of the links to be updated without accidentally changing the meaning or structure of the sentence containing the link. [^1] [^4]

> [!warning]
> Do not assume display text is immutable. See: [Link display text is not immutable](obsidian-link-diplay-text-is-mutable.md)[^4]

# History

[^1]: [202305300005](../entries/202305300005.md)

[^2]: [202305300303](../entries/202305300303.md)

[^3]: [202305300307](../entries/202305300307.md)

[^4]: [202306020039](../entries/202306020039.md)
