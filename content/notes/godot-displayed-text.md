---
title: Godot Displayed Text
created: 2024-10-23T17:45:14Z
modified: 2024-10-28T04:50:15Z
aliases:
- Godot Displayed Text
tags:
- godot
---

# Godot Displayed Text

[`RichTextLabel`](godot-rich-text-label.md) and `Label` both have a set of properties called "Displayed Text" that you can use to control how much of the text is shown on screen and how that text is displayed.[^1]

`visible_characters` and `visible_ratio` allow you to define how much of the text you would like to show, allowing you to do animations that make the text appear like it is being typed out. `visible_characters` allows you to do this by defining how many characters to show while `visible_ratio` allows you to do this by defining a percentage (between the value of `0.0` and `1.0`) [^1]

`visible_characters_behavior` lets you define how those characters appear onto the screen. `VC_CHARS_BEFORE_SHAPING` looks exactly like text being typed by a user onto the screen, while `VC_CHARS_AFTER_SHAPING` shows the text where it would be after all the text is typed, preventing the visual flicker when text is added to the end of a line before jumping to the next line due to reaching the maximum length of the line. [^1]

I'm not sure what the other values for `visible_characters_behaviour` does exactly, though I imagine you'll have to use them if you are integrating support for RTL languages. [^1]

# Example

For example, consider the following examples of a `RichTextLabel` with the Lorem Ipsum text inside of a `CenterContainer`. I added a simple script which increases the `visible_characters` value from 0 to its maximum value every frame. [^2]

```gdscript
extends RichTextLabel

func _ready() -> void:
	visible_characters = 0

func _process(_delta: float) -> void:
	visible_characters += 1
```

The `VC_CHARS_BEFORE_SHAPING` value causes the text to "jump" to the next line when there isn't enough space and the first line of the text moves further and further up the screen as more text is displayed: [^2]

![](godot-displayed-text-before.mp4)

The `VC_CHARS_AFTER_SHAPING` value causes the text to always appear in the right place: [^2]

![](godot-displayed-text-after.mp4)

As an additional note, all of the Displayed Text properties take BBCode into account, so it will always be displayed properly: [^2]

![](godot-displayed-text-bbcode.mp4)

[^1]: [20241023170651](../entries/20241023170651.md)
[^2]: [20241023175859](../entries/20241023175859.md)
