---
title: "`reduce` returns first value in array when accumulator is `null`"
created: 2025-03-07T17:37:00Z
aliases:
- "`reduce` returns first value in array when accumulator is defined as `null`"
tags:
- godot
---

# `reduce` returns first value in array when accumulator is `null`

`Array.reduce` as of Godot 4.4 will use the first element in the array when the accumulator is either undefined or explicitly set to `null` by the user, contrary to how JavaScript, F#, and Python works. [^1]

This means that you cannot write a function to pass to `reduce` that would fold over a list and return the best suitable match based on some criteria or `null` if none of those elements are appropriate. This is because it could keep picking an inappropriate result if one exists at the front of the list. [^1]

If you are familiar with Haskell, another way of thinking about it is that `reduce` in GDScript silently turns into `foldl1` when `Nothing` is passed to `foldl` as the initial value for the accumulator. [^1]

This behavior is documented in the documentation for [`reduce`](https://docs.godotengine.org/en/4.4/classes/class_array.html#class-array-method-reduce), this is because of how the `accum` parameter works: [^1]

> The method takes two arguments: the current value of `accum` and the current array element. If `accum` is `null` (as by default), the iteration will start from the second element, with the first one used as initial value of `accum`.

[^1]: [20250307170955](../entries/20250307170955.md)
