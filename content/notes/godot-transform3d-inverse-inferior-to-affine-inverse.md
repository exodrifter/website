---
title: "`inverse` is an inferior version of `affine_inverse`"
aliases:
- "`inverse` is an inferior version of `affine_inverse`"
tags:
- godot
---

# `inverse` is an inferior version of `affine_inverse`

In Godot 4.2.2, the implementation of [`inverse`](https://docs.godotengine.org/en/4.2/classes/class_transform3d.html#class-transform3d-method-inverse) in `Transform3D` reads as follows:

```
Transform3D Transform3D::inverse() const {
	// FIXME: this function assumes the basis is a rotation matrix, with no scaling.
	// Transform3D::affine_inverse can handle matrices with scaling, so GDScript should eventually use that.
	Transform3D ret = *this;
	ret.invert();
	return ret;
}
```

See: https://github.com/godotengine/godot/blob/4.2.2-stable/core/math/transform_3d.cpp#L52-L58

Instead of using `inverse`, you should always use `affine_inverse` instead.

I consider this issue to be a [Godot crime](godot-crimes.md).

# History

- [202312251644](../entries/202312251644.md)
