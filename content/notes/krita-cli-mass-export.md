---
title: Mass export Krita files in the CLI
created: 2024-10-08T20:56:41Z
modified: 2025-03-03T20:23:20Z
aliases:
- Mass export Krita files in the CLI
tags:
- krita
---

# Mass export Krita files in the CLI

To mass export Krita files on the command line, you can treat the Krita file as a zip file and extract `mergedimage.png`. For example, in bash: [^1]

```sh
unzip -p image.kra mergedimage.png >image.png
```

To export all Krita documents in a directory, in bash: [^2]

```bash
for a in *.kra; do file=$(basename $a .kra); unzip -p $file.kra mergedimage.png >$file.png; optipng $file.png; done
```

---

According to the documentation, you can also invoke the Krita program with an export flag, but this didn't work for me and I end up with a blank image instead: [^1]

```sh
krita image.kra --export --export-filename image.png
```

[^1]: [20241008204358](../entries/20241008204358.md)
[^2]: [20250303201836](../entries/20250303201836.md)
