---
title: Image decompression doesn't work in exported builds
aliases:
- Image decompression doesn't work in exported builds
tags:
- godot
---

# Image decompression doesn't work in exported builds

The `decompress` function is described as follows:

> [docs.godotengine.org](https://docs.godotengine.org/en/4.2/classes/class_image.html#class-image-method-decompress):
>
> **`Error decompress()`**
>
> Decompresses the image if it is VRAM compressed in a supported format. Returns `@GlobalScope.OK` if the format is supported, otherwise `@GlobalScope.ERR_UNAVAILABLE`.
>
> **Note:** The following formats can be decompressed: DXT, RGTC, BPTC. The formats ETC1 and ETC2 are not supported.

However, the decompress function may still return `ERR_UNAVAILABLE` anyway when the game is exported, because not all of the image compression and decompression libraries are included in export builds:

> [clayjohn](https://github.com/godotengine/godot/issues/79932#issuecomment-1652303933):
>
> Looks like most of the image compression/decompression libraries aren't included in export builds.

If you are trying to decompress an image previously compressed by `Image.compress`, it appears that only `COMPRESS_S3TC` can be decompressed at runtime with the default export template.

## History

![20240806_165154](../entries/20240806_165154.md)
