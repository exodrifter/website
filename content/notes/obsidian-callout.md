---
title: Obsidian Callout
created: 2023-05-30T02:32Z
modified: 2024-10-11T06:14:18Z
aliases:
- Obsidian Callout
- Obsidian Callouts
tags:
- obsidian
---

# Obsidian Callout

Used to render a nicely formatted callout; one of the additional syntax options in [Obsidian Flavored Markdown](obsidian-flavored-markdown.md).

# Syntax

In a quote, add `[!note]` to the first line, where `note` is the _type identifier_. After the `]`, an optional character can be added to make the callout foldable; `+` to expand the foldout by default or `-` to collapse the foldout by default. Finally, optional additional text until the end of the line can be added to specify the title of the callout. [^1] [^2] [^3]

**One-line callout example:**

```
> [!note]
```

> [!note]

**Expanded foldout example:**

```
> [!note]+ Expanded note
> This note is expanded by default
```

> [!note]+ Expanded note
> This note is expanded by default

# Types

The following are different type identifiers you can use with callouts.

> [!note]
> ```
> > [!note]
> > Hello World!
> ```

> [!abstract]
> ```
> > [!abstract]
> > Hello World!
> ```
> Aliases: `summary`, `tldr`

> [!info]
> ```
> > [!info]
> > Hello World!
> ```

> [!todo]
> ```
> > [!todo]
> > Hello World!
> ```

> [!tip]
> ```
> > [!tip]
> > Hello World!
> ```
> Aliases: `hint`, `important`

> [!success]
> ```
> > [!success]
> > Hello World!
> ```
> Aliases: `check`, `done`

> [!question]
> ```
> > [!question]
> > Hello World!
> ```
> Aliases: `help`, `faq`

> [!warning]
> ```
> > [!warning]
> > Hello World!
> ```
> Aliases: `caution`, `attention`

> [!failure]
> ```
> > [!failure]
> > Hello World!
> ```
> Aliases: `fail`, `missing`

> [!danger]
> ```
> > [!danger]
> > Hello World!
> ```
> Aliases: `error`

> [!bug]
> ```
> > [!bug]
> > Hello World!
> ```

> [!example]
> ```
> > [!example]
> > Hello World!
> ```

> [!quote]
> ```
> > [!quote]
> > Hello World!
> ```
> Alias: `cite`

[^1]: [202305300232](../entries/202305300232.md)

[^2]: [202305300238](../entries/202305300238.md)

[^3]: [202305300240](../entries/202305300240.md)
