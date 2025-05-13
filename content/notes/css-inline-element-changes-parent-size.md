---
title: Inline Element Changes Parent Size
created: 2025-05-13T08:07:05Z
aliases:
- Inline Element Changes Parent Size
tags:
- css
---

# Inline Element Changes Parent Size


The height of parent elements can change when an inline-level element has the default value for `vertical-align`, which is `baseline`. This is because `baseline` may result in the browser adding extra space above and below the element to align the baselines of the inline-level element and its parent element, which can cause the parent to be larger than expected. [^1]

Changing `vertical-align` from the default value of `baseline` to `top` or `bottom` both fix the issue. [^1]

[^1]: [20250513074903](../entries/20250513074903.md)
