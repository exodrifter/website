---
title: Pandoc creates duplicate footnotes
created: 2025-07-15T23:46:14Z
aliases:
- Pandoc creates duplicate footnotes
tags:
- pandoc
---

# Pandoc creates duplicate footnotes

Pandoc's AST doesn't maintain footnote references at all, instead opting to inline the footnote's contents into the AST whenever a footnote appears. The issue [jgm/pandoc#1603](https://github.com/jgm/pandoc/issues/1603), which is about this problem, has been open since 2014. A fix would have to involve changing the Pandoc AST.
