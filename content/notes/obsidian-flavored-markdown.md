---
title: Obsidian Flavored Markdown
created: 2023-05-30T00:32Z
aliases:
- Obsidian Flavored Markdown
tags:
- markdown
- obsidian
---

# Obsidian Flavored Markdown

The [Markdown Flavor](markdown-flavor.md) that [Obsidian](obsidian.md) uses for [Obsidian Notes](obsidian-note.md).

It has the following characteristics:
* It implements the [Commonmark](commonmark.md) specification
* It implements some functionality from Github Flavored Markdown
* It implements some functionality from LaTeX (unsure how much exactly)
* Within HTML blocks, it does not support Markdown or blank lines

# Obsidian-Specific Markdown Syntax

> [!warning]
> This syntax is specific to Obsidian! This syntax is not supported in general outside the Obsidian ecosystem.

Obsidian adds the following syntax:

Syntax | Feature
-------|--------
`[[ ]]` | [Internal Links](obsidian-internal-link.md)
`![[ ]]` | [Embeds](obsidian-embed.md)
`%% %%` | [Obsidian Comments](obsidian-comments.md)
`> [!note]` | [Callouts](obsidian-callout.md)

# History

![202305300032](../entries/202305300032.md)
