---
title: Obsidian Comments
created: 2023-06-02T02:16Z
aliases:
- Obsidian Comment
- Obsidian Comments
tags:
- obsidian
---

# Obsidian Comments

Official Documentation: [help.obsidian.md](https://help.obsidian.md/Editing+and+formatting/Basic+formatting+syntax#Comments)

Used to hide text from read mode; one of the additional syntax options in [Obsidian Flavored Markdown](obsidian-flavored-markdown.md).

# Syntax

You can comment out parts of a document by surrounding the text to comment out with `%%`. For example:

```markdown
This sentence is missing a %%word%% in read mode.

%%
This only appears in edit mode.
%%
```

This results in:
> This sentence is missing a %%word%% in read mode.
>
> %%
> This only appears in edit mode.
> %%

# History

![202306020216](../entries/202306020216.md)
