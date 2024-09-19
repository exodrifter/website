---
title: Quartz does not set the date properly
aliases:
- Quartz does not set the date properly
tag:
- quartz
---

# Quartz does not set the date properly

Quartz's documentation says the following:

> [Syntax, Authoring Content, Quartz Documentation](https://quartz.jzhao.xyz/authoring-content#syntax):
>
> `date`: A string representing the day the note was published. Normally uses `YYYY-MM-DD` format.

This works if `defaultDateType` is set to `created`. However, you might find that all of the dates are not set correctly if you change the `defaultDateType` to `modified` or `published`. 

This is because for these date types, the date is actually read from different fields in the default `CreatedModifiedDate` plugin. For `modified`, the field is read from `lastmod`, `updated`, or `last-modified`. For `published`, the date is read from `publishDate`.

# History

- [20240915073724](../entries/20240915073724.md)
