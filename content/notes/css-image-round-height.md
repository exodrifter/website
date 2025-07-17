---
title: How to round the height of an image with CSS
created: 2025-07-18T03:47:11-07:00
aliases:
  - How to round the height of an image with CSS
tags:
  - css
---

# How to round the height of an image with CSS

Lets say you want to render an image in an HTML document that uses `round` to round the height to some interval. Consider the following constraints: [^1]

- The image needs to take up 100% of the width of the parent container
- The image needs to maintain its aspect ratio
- The image should have as little empty space as possible around it

In order to do this, we must first embed the aspect ratio of the image into the image's `style` attribute in the HTML code. For example: [^1]

```html
<figure>
<img src="20250516012109_crowd.jpg" style="--ratio:calc(4032/1794)" alt="The crowded showcase area in the Garage on the first day. My game no signal is partially visible at the bottom.">
</figure>
```

Next, we need to set the parent of the image to have `container-type: inline-size`, which allows us to access the `cqi` unit. This is how we're able to get the width of the parent while calculating the height. Our CSS will then look something like this, if our interval is in the `--grid-size` variable: [^1]

```css
figure:has(> img) {
    container-type: inline-size;

    img {
        width: 100%;
        height: round(up, calc(100cqi / var(--ratio)), var(--grid-size));
        object-fit: contain;
    }
}
```

[^1]: [20250718103912](../entries/20250718103912.md)
