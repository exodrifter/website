---
title: How do I delete EXIF metadata with exiftool?
created: 2024-09-23T17:47:50Z
aliases:
- How do I delete EXIF metadata with exiftool?
---

# How do I delete EXIF metadata with exiftool?

With `exiftool` installed, use the following command: [^1]

```sh
exiftool -EXIF= path/to/file
```

`-EXIF=` tells exiftool to copy only the listed EXIF metadata to a new copy of the picture, but since our list is empty this has the effect of deleting all of the EXIF metadata from the picture. A backup image with the original metadata will be found in the same path with `_original` appended to their filename. [^1]

You can confirm that the EXIF metadata is deleted by running `exiftool path/to/file`. [^1]

[^1]: [20240923174750](entries/20240923174750.md)
