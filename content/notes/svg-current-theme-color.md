---
title: Use color scheme in SVGs
created: 2024-09-15T10:21:02Z
modified: 2025-07-14T22:23:24Z
aliases:
- Use color scheme in SVGs
- SVGs don't use the current color on websites
tags:
- css
- html
- svg
---

# Use color scheme in SVGs

When you are embedding a logo onto a website, you will often want to switch between two different versions of the SVG depending on the user's color scheme.

To do this, change the SVG to use `currentColor` as the `color` for strokes and add the following `style` element: [^1]

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

Note: While this is part of the accepted specification, this will still not work if this SVG is embedded into an HTML page on WebKit browsers like Safari. In order for this to work in WebKit browsers, you will also need to inline the SVG into the HTML page. [^2]

[^1]: [20240915101218](../entries/20240915101218.md)
[^2]: [20250714210539](../entries/20250714210539.md)
