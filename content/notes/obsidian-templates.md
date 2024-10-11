---
title: Obsidian Templates
created: 2023-06-01T19:47Z
modified: 2023-06-01T23:39Z
aliases:
- Obsidian Templates
tags:
- obsidian
---

# Obsidian Templates

Official documentation: [help.obsidian.md](https://help.obsidian.md/Plugins/Templates)

A [core Obsidian plugin](obsidian-core-plugin.md) which allows you to create new notes with predefined snippets of text or insert them into the current note.

# Features

It can do the following things:
* Insert the contents of a template note into the current note.
* Insert the current date in the default date format into the current note (`Templates: Insert current date` command).
* Insert the current time in the default time format into the current note (`Templates: Insert current time` command).

# Template Note

A **template note** is a note which is in the path that the Obsidian Templates `Template folder location` setting is set to.

# Template Variables

A **template variable** is a string which will be substituted with values when the template is inserted into the current note or used to create a new note.

Variable | Description
---------|------------
`{{title}}` | Title of the active note.
`{{date}}` | Today's date in the default format as defined by the `Date format` setting.
`{{date:format}}` | Today's date in the format `format`
`{{time}}` | Today's time in the default format as defined by the `Time format` setting.
`{{time:format}}` | Current time in the format `format`

`format` can be a Moment.js [format string](https://momentjs.com/docs/#/displaying/format/).

Note that while a format string can be used with `{{date}}` or `{{time}}`, either of the date or time formats can be changed to use a format that has both the date and time in it. This works for the default format settings too.

# History

![202306011947](../entries/202306011947.md)

![202306012327](../entries/202306012327.md)

![202306012331](../entries/202306012331.md)

![202306012339](../entries/202306012339.md)
