---
title: SVGs don't use the current color on websites
created: 2024-09-15T10:21:02Z
modified: 2024-09-19T04:26:37Z
aliases:
- SVGs don't use the current color on websites
---

# SVGs don't change color to match current theme on websites

Changing the color to `currentColor` is not sufficient for setting the color of an SVG to match with the current theme. Instead, change the SVG to have the following style block:

```xml
<svg xmlns="http://www.w3.org/2000/svg">
  <defs>
    <style>
      svg {
        color: black;
        color-scheme:light dark;
      }
      @media (prefers-color-scheme:dark) {
        svg {
          color: white;
        }
      }
    </style>
  </defs>
</svg>
```

# History

- [20240915101218](../entries/20240915101218.md)
