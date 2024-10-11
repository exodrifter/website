---
title: Obsidian Embed
created: 2023-06-02T01:34Z
modified: 2023-06-02T01:43Z
aliases:
- Obsidian Embed
- Obsidian Embeds
tags:
- obsidian
---

# Obsidian Embed

Official Documentation: [help.obsidian.md](https://help.obsidian.md/Linking+notes+and+files/Embedding+files)

Used to include the content of another file in a markdown note; one of the additional syntax options in [Obsidian Flavored Markdown](obsidian-flavored-markdown.md).

# Syntax

In all cases, to make an embed you must write an [Obsidian Internal Link](obsidian-internal-link.md) with an exclamation mark (`!`) at the beginning.

## Embedding notes

These embeds may still link to specific headings or blocks. In these cases, just the heading or just the block is embedded instead of the whole file.

## Embedding images

The size of the image may be changed by setting the display text of the internal link to a string specifying the dimensions:

For example, for dimensions of width of 100 and a height of 145:

```
![[Foobar.jpg|100x145]]
```

Or, with a width of 100 and a height that keeps the original aspect ratio:

```
![[Foobar.jpg|100]]
```

## Embedding audio

The embed for audio files will show a player that can be used to play back the audio.

## Embedding PDFs

The embed may be directed to start on a specific page by adding `#page=n` to the link destination, where `n` is the page number.

# History

![202306020134](../entries/202306020134.md)

![202306020140](../entries/202306020140.md)

![202306020142](../entries/202306020142.md)

![202306020143](../entries/202306020143.md)
