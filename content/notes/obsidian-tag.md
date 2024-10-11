---
title: Obsidian Tag
created: 2023-05-30T00:07Z
modified: 2024-10-11T06:10:30Z
aliases:
- Obsidian Tag
- Obsidian Tags
tags:
- obsidian
---

# Obsidian Tag

A string which can be associated with an [Obsidian Note](obsidian-note.md).

They can be added inline to the content of the note by adding a hashtag symbol (`#`) followed by the string, or they can be added to the [Obsidian Metadata](obsidian-metadata.md).

It can only contain the following characters: [^3]
* Alphabetical letters
* Numbers
* Underscore (`_`)
* Hyphen (`-`)
* Forward slash (`/`) for Nested tags

It must also contain at least one non-numerical character.

# Nested Tag

A tag which is nested in another tag by using forward slashes (`/`) in the tag name. This creates "folders" for the tags to be in. [^4]

# How to use

Tags should only be used for two things:

* **Ephemeral data** - Such as a temporary status like `#todo` or `#read`. These tags are not expected to be part of the knowledge base and are just a way for me to see what needs to be done. [^1]
* **Views** - To make it easier to select a subset of notes in the graph view that would be otherwise difficult to make a search of. This is useful especially when the subset of notes is not otherwise separated cleanly into a distinct hierarchy such as a folder in the file system. [^2]

# History

[^1]: [202305300007](../entries/202305300007.md)

[^2]: [202305300008](../entries/202305300008.md)

[^3]: [202305300207](../entries/202305300207.md)

[^4]: [202305300211](../entries/202305300211.md)
