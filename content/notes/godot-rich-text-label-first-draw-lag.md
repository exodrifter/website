---
title: "`RichTextLabel` lags on first draw"
aliases:
- "`RichTextLabel` lags on first draw"
tags:
- godot
---

# `RichTextLabel` lags on first draw

`RichTextLabel` uses `TextParagraph` internally to draw text, but since `TextParagraph` caches some information lazily there can be a lag spike when drawing the `RichTextLabel` for the first time.

To get around this issue, you can disable the use of system fonts as a fallback or use the `TextParagraph` class directly, and force it to cache the information it needs before the first draw call:

```gdscript
@tool
class_name CachedTextLabel
extends Control

@export_multiline var text: String:
	set(value):
		if text != value:
			text = value

			var font := get_theme_default_font()
			var font_size := get_theme_default_font_size()
			paragraph = TextParagraph.new()
			paragraph.add_string(text, font, font_size)

			queue_redraw()

var paragraph: TextParagraph

func _ready() -> void:
	# Force the paragraph to cache some data before the first draw
	paragraph.get_size()

func _draw() -> void:
	var start := Time.get_ticks_msec()
	paragraph.width = size.x
	paragraph.break_flags = TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND
	paragraph.justification_flags = TextServer.JUSTIFICATION_NONE
	paragraph.alignment = HORIZONTAL_ALIGNMENT_LEFT
	paragraph.draw(get_canvas_item(), Vector2.ZERO)
	var end := Time.get_ticks_msec()
	print("_draw: ", end - start, "ms")
```

Unfortunately, `TextParagraph` does not support BBCode.

# History

- [20240611220958](../entries/20240611220958.md)
- [20240607184945](../entries/20240607184945.md)
