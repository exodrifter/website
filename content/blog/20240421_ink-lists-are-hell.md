---
title: ink lists are hell
publishDate: 2024-04-21
aliases:
- ink lists are hell
---

Posted at:
- [cohost!](https://cohost.org/exodrifter/post/5659898-ink-lists-are-hell) on 2024-04-21 at 23:15 UTC

# ink lists are hell

Ink is a dialogue scripting language that I absolutely loathe, but to be fair to them it can be difficult to design a scripting language meant for users who are primarily non-technical. Recently, I was reading their documentation so I could help someone with it and I learned how lists work in Ink. Here's what they look like:

```
LIST colors = red, green, blue
```

If you have a technical background like me, you might assume that this defines a new variable that is of the type `list` which contains the values `red`, `green`, and `blue` in it. Is this what Ink does? **No.**

```
LIST colors = red, green, blue
{colors} // prints nothing
```

Oh, okay, it's not set to anything... interesting. So... `colors` is null? How do we set it to a value?

## ink lists are enums

Well, that's because Ink lists are actually enums. See, you can set the value of `colors`:

```
LIST colors = (red), green, blue
{colors} // prints "red"
~ colors = green
{colors} // prints "green"
```

"Oh okay," you say, "So we're saying that `colors` can be none of those values or one of those values and we set it to `red`. Kind of weird they use the `LIST` keyword for that though, isn't that just an enum type? Why don't they call it an enum instead of a list?"

Well, yeah, I mean, it's kind-of like an enum. You can do what you might expect for enum types like ask what values `colors` could possibly have:

```
LIST colors = red, green, blue
{LIST_ALL(colors)} // prints "red, green, blue"
```

As an aside, you can also declare more variables that use the same enum, like this:

```
LIST colors = red, green, blue
VAR colors_a = red
```

You can see here that both colors and colors_a share the same enum type, since they both have the same possible values:

```
LIST colors = red, green, blue
VAR colors_a = red
{LIST_ALL(colors)} // prints "red, green, blue"
{LIST_ALL(colors_a)} // prints "red, green, blue"
```

It just so happens that `LIST colors` actually does two things:
- Declares an named enum with those potential values
- Declares a named variable with whatever value was assigned

You can also get the next and previous enum values by incrementing or decrementing them like numbers:

```
LIST colors = (red), green, blue
{colors} // prints "red"
~ colors++
{colors} // prints "green"
~ colors--
{colors} // prints "red"
```

Wait a second, it's like a number?

## ink lists are numbers

Oh, okay, so ink lists are kind-of like enums, but they're also kind-of like numbers. Can we see what numbers are assigned to each enum? You sure can, because ink lists are kind-of like numbers! You can use `LIST_VALUE` to convert the value into a number:

```
LIST colors = (red), green, blue
{LIST_VALUE(colors)} // prints "1"
~ colors++
{LIST_VALUE(colors)} // prints "2"
~ colors++
{LIST_VALUE(colors)} // prints "3"
```

And you can convert a number back into the enum too:

```
LIST colors = red, green, blue
colors = colors(2)
{colors} // prints "green"
```

As you can see, ink lists are 1-indexed and numbers are assigned sequentially. Can you assign numbers to the possible values? You can! Here's what that looks like:

```
LIST colors = red=1, (green=3), blue=5
```

You can also compare them!

```
LIST colors = red=1, (green=3), blue=5
{ red < green } // prints "true"
{ green < red } // prints "false"
{ red == blue } // prints "false"
{ colors <= green } // prints "true"
```

Great, so... it's a number, right? We _should_ be able to add the difference between different possible values to get to the respective numbers:

```
LIST colors = red=1, (green=3), blue=5
~ colors += 2
{colors} // prints "blue"
~ colors -= 4
{colors} // prints "red"
```

Nice! Okay, and obviously, since adding two numbers is the same as adding the sum of the numbers, you should get the same result, right? **No**; they're only kind-of like numbers:

```
LIST colors = red=1, (green=3), blue=5
~ colors++
{colors} // prints nothing
~ colors--
{colors} // still prints nothing
```

In fact, whenever you do some arithmetic and the resulting value is invalid, it's shunted off into the void and replaced with `0`.

```
LIST colors = red, green, blue
{colors} // prints nothing
{colors < green} // prints "true"
{LIST_VALUE(colors)} // prints "0"
```

"Ah, okay," You say once again, as you recline in your chair, "So that's why they use 1-indexing. It's because they're using `0` as a null-like value that you can't do anything with."

But you're wrong! Ink is perfectly happy letting you use the value `0`, because we can do that ourselves just fine:

```
LIST colors = (red=0), green=1, blue=3
{colors} // prints "red"
{LIST_VALUE(colors)} // prints "0"
~ colors++
{colors} // prints "green"
{LIST_VALUE(colors)} // prints "1"
```

...but the moment the value is invalid it becomes the `0` we can't do anything with instead of the `0` we _can_ do something with:

```
LIST colors = (red=0), green=1, blue=3
{colors} // prints "red"
{LIST_VALUE(colors)} // prints "0"
~ colors++
{colors} // prints "green"
{LIST_VALUE(colors)} // prints "1"
~ colors++
{colors} // prints nothing
{LIST_VALUE(colors)} // prints "0"
~ colors++
{colors} // prints nothing
{LIST_VALUE(colors)} // prints "0"
```

Well, okay, to be pedantic we can still do something with the `0` by converting back into the enum:

```
LIST colors = red=0, blue=2, green=3
{colors} // prints "red"
{LIST_VALUE(colors)} // prints "0"
~ colors++
{colors} // prints nothing
{LIST_VALUE(colors)} // prints "0"
{color(LIST_VALUE(colors))} // prints "red"
```

Anyway, since ink lists are enums that are also numbers, you can of course add and subtract them!

```
LIST colors = (red=1), green=2, blue=3
{colors} // prints "red"
~ colors += green
{colors} // prints "red, green"
```

Wait a second --

## ink lists are lists

"That's right! Have you forgotten?" I say, shaking you awake by the shoulders. When Ink says `LIST` it's definitely a list. Like, kind-of. You can of course assign lists multiple values...

```
LIST colors = (red), (green), blue
{colors} // prints "red, green"
```

...perform some straightforward list operations...

```
LIST colors = (red), (green), blue
{LIST_COUNT(colors)} // prints "2"
{LIST_MIN(colors)} // prints "red"
{LIST_MAX(colors)} // prints "green"
{LIST_RANDOM(colors)} // prints either "red" or "green"

~ colors += blue // Adds blue to the list
{colors} // prints "red, green, blue"
~ colors -= blue // Removes blue from the list
{colors} // prints "red, green"
```

...and you can compare them to each other by value:

```
LIST colors = (red), (green), blue
VAR colors_a = (red, green)
VAR colors_b = (green)
{colors_a == colors_b} // prints "false"

// Remember that `colors` is also a variable?
{colors == colors_a} // prints "true"
{colors == colors_b} // prints "false"
```

"But wait, so ink lists are lists _and_ numbers?" You ask, "What does that mean for the operations from earlier like `LIST_VALUE`, arithmetic operations, and comparisons?"

Well, in the case of `LIST_VALUE`, it always returns the value that is the largest:

```
LIST colors = (red), (green), blue
{LIST_VALUE(colors)} // prints "2"
```

In other words, it's the same as `LIST_MAX`. For arithmetic operations, the operation is applied to every element in the list:

```
LIST colors = (red), (green), blue
~ colors++
{colors} // prints "green, blue"
```

For the functional programmers reading this, it's like `fmap`! Kinda. So obviously, I think this qualifies Ink as a fully functional programming language (/j). And for comparisons, well:

```
LIST colors = red, green, blue
VAR colors_a = (red, green)
VAR colors_b = (blue)
{colors_a < colors_b} // prints "true"
```

How does that work?

## ink lists are ranges

As it turns out, ink lists are _also_ ranges, but **not** number ranges; you can only use them with defined values.

```
LIST colors = (red), (green), blue, yellow
{colors < blue} // compiles
{colors < 0} // compiler error
```

`A < B` returns true if the range of A is entirely to the left of the entirety of B. `A > B` does the opposite; it returns true if the range of A is entirely to the right of B. In both cases, overlaps in the range return false.

```
LIST colors = red, green, blue, yellow
VAR a = (red, green)
VAR b = (green, blue)
VAR c = (blue, yellow)

{a < c} // prints "true"
{a < b} // prints "false"
{b < c} // prints "false"
{c < a} // prints "false"

{c > a} // prints "true"
{b > a} // prints "false"
{c > b} // prints "false"
{a > c} // prints "false"
```

`A <= B` is the same as `<` and `A >= B` is the same as `>` except that _overlaps_ are allowed:

```
LIST colors = red, green, blue, yellow
VAR a = (red, green)
VAR b = (green, blue)
VAR c = (blue, yellow)

{a <= c} // prints "true"
{a <= b} // prints "true"
{b <= c} // prints "true"
{c <= a} // prints "false"

{c >= a} // prints "true"
{b >= a} // prints "true"
{c >= b} // prints "true"
{a >= c} // prints "false"
```

And notably, doing `A > B or A == B` is not equivalent to `A >= B`:

```
LIST colors = red, green, blue
VAR a = (red, green)
VAR b = (red, blue)
{a < b or a == b} // prints "false"
{a <= b} // prints "true"
```

And how does this work with empty ranges? Well, the comparison operators treat an empty list some number that is less than all possible values in the list:

```
LIST colors = red=-1, green=0, blue=1
{() < red} // prints "true"
{() < blue} // prints "true"
{red < ()} // prints "false"
{blue < ()} // prints "false"
```

Empty lists suck though, so we should probably stick to lists that actually have stuff in them. Lets append lists together:

```
LIST colors = (red), (green), blue
VAR colors_a = (green)
{colors} // prints "red, green"
{colors + colors_a} // also prints "red, green"
```

Oh no.

## ink lists are sets

Ink lists are also sets because they can't contain duplicate values. And since they are sets, you can do the usual things with them like invert them...

```
LIST colors = (red), (green), blue
{LIST_INVERT(colors)} // prints "blue"
```

...do union, difference, and intersection operations...

```
LIST colors = red, green, blue
VAR colors_a = (red)
VAR colors_b = (red, blue)
{colors_a + colors_b} // prints "red, blue"
{colors_a - colors_b} // prints nothing
{colors_b - colors_a} // prints "blue"
{colors_a ^ colors_b} // prints "red"
```

...and test whether or not a set contains something with `?` and whether or not it doesn't have something with `!?`:

```
LIST colors = (red), (green), blue

{colors ? red} // prints "true"
{colors ? (red, green)} // prints "true"
{colors ? (red, green, blue)} // prints "false"

{colors !? red} // prints "false"
{colors !? (red, green)} // prints "false"
{colors !? (red, green, blue)} // prints "true"
```

Obviously, this works for variables too:

```
LIST colors = red, green, blue
VAR colors_a = (red)
VAR colors_b = (red, green, blue)

{colors_a ? colors_b} // prints "false"
{colors_b ? colors_a} // prints "true"
{colors_a !? colors_b} // prints "true"
{colors_b !? colors_a} // prints "false"

{colors ? colors_a} // prints "false"
{colors ? colors_b} // prints "false"
{colors !? colors_a} // prints "false"
{colors !? colors_b} // prints "false"
```

Oh, right, `colors` is also a variable and it's not currently set to anything, so it is empty. Ink actually asserts that nothing can contain the empty list, not even the empty list itself:

```
LIST colors = red, green, blue
VAR colors_a = (red)
VAR colors_b = (red, green, blue)

{colors_a ? ()} // prints "false"
{colors_b ? ()} // prints "false"
{colors ? ()} // prints "false"
{() ? ()} // prints "false"

{colors_a !? ()} // prints "true"
{colors_b !? ()} // prints "true"
{colors !? ()} // prints "true"
{() !? ()} // prints "true"
```

Which is, you know, fun:

```
LIST all_keys = house_key, padlock_key, mail_key
VAR inventory = (mail_key)
VAR required_keys = (house_key, padlock_key)

VAR can_open_door = false
~ can_open_door = inventory ? required_keys
{can_open_door} // prints "false"

// break the door
~ required_keys -= house_key
// break the lock
~ required_keys -= padlock_key

~ can_open_door = inventory ? required_keys
{can_open_door} // prints "false", guess we can't open the door still even though it has no requirements
```

 Anyway, that's about all ink lists can do. It's kind of a funny little thing where you have some constrained set of values a variable can be and you can do a _bunch_ of different things with them. But, at least it guarantees the invariant that a variable can only be a few different things and -- wait -- oh no...

## ink lists are untyped

```
LIST colors = red, green, blue
LIST polygons = triangle, square, pentagon
VAR shape = ()
~ shape += red
~ shape += triangle
{shape} // prints "red, triangle"
```

Ink lists are not actually constrained to only one possible type. You can, at any time, add lists of different types together. So, what does that mean for, well, everything else we reviewed?

Generally speaking, when there is a function that returns one value, you should imagine that it returns the first result in the list that matches. For example:

```
LIST colors = red, green, blue
LIST polygons = triangle, square, pentagon
VAR shape_a = (red, triangle)
VAR shape_b = (triangle, red)
{LIST_MAX(shape_a)} // prints "red"
{LIST_MAX(shape_b)} // prints "triangle"
```

And when you treat it as a range, all of the values are turned into numbers first for the sake of comparing them:

```
LIST colors = red, green, blue
LIST polygons = triangle, square, pentagon
VAR shape_a = (red, square)
VAR shape_b = (green, triangle)
{shape_a < shape_b} // prints "false"
{shape_a <= shape_b} // prints "true"
```

And when a function depends on all of the possible values of a list, it only considers the possible values of every type that is currently present in the list, or the type that was last present in the list if it is empty:

```
LIST colors = red, green, blue
LIST polygons = triangle, square, pentagon

VAR shape = (red, square)
{LIST_ALL(shape)} // prints "red, triangle, green, square, blue, pentagon"
{LIST_INVERT(shape)} // prints "triangle, green, blue, pentagon"

~ shape -= red
{LIST_ALL(shape)} // prints "triangle, square, pentagon"
{LIST_INVERT(shape)} // triangle, pentagon

~ shape -= square
{LIST_ALL(shape)} // prints "triangle, square, pentagon"
{LIST_INVERT(shape)} // prints "triangle, square, pentagon"

~ shape += red
{LIST_ALL(shape)} // prints "red, green, blue"
{LIST_INVERT(shape)} // prints "green, blue"

~ shape -= red
{LIST_ALL(shape)} // prints "red, green, blue"
{LIST_INVERT(shape)} // prints "red, green, blue"
```

And finally, you can replace the list with a value of a different type:

```
LIST colors = red, green, blue
colors = 2 // This is a number now instead of a list
{colors} // prints "2"
```

As a side note, [according to the official documentation](https://github.com/inkle/ink/blob/6a512190365002f54bd501b0863ded40123cb8e5/Documentation/WritingWithInk.md#6-multi-list-lists), using multiple list types for a variable is the idiomatic way to do record types in Ink:

> This allows us to use lists - which have so far played the role of state-machines and flag-trackers - to also act as general properties, which is useful for world modelling.
>
> This is our inception moment. The results are powerful, but also more like "real code" than anything that's come before.

But this is a bad idea because you can accidentally nuke other parts of your state:

```
LIST state = on, off
LIST temperature = cold, tepid, hot
VAR kettle = (on, cold)
~ kettle = hot // whoops
{kettle} // prints "hot"
```

And you can't enforce invariants like making sure that there is only one possible value for each field:

```
LIST state = on, off
LIST temperature = cold, tepid, hot
VAR kettle = (on, cold)
~ kettle = LIST_INVERT(kettle) // whoops
{kettle} // prints "off, tepid, hot"
```

Okay! I think that's everything. I think I'm gonna head out before the code crime police shows up. Maybe I'll read some yuri manga...