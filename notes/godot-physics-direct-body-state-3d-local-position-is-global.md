---
aliases:
- "`get_contact_local_position` returns global position"
---


# `get_contact_local_position` returns global position

In Godot 4.2.2, `get_contact_local_position` is documented as follows:

> [Godot 4.2.2 docs](https://docs.godotengine.org/en/4.2/classes/class_physicsdirectbodystate3d.html#class-physicsdirectbodystate3d-method-get-contact-local-position):
>
> Returns the position of the contact point on the body in the global coordinate system.

Despite the function being labeled as a "local" position, the documentation here is correct and a global position is returned.

The function has not been renamed in an effort to not break compatibility (See [godotengine/godot#89938](https://github.com/godotengine/godot/issues/89938#issuecomment-2022364558)).

## History

![20240703_184120](entries/20240703_184120.md)
