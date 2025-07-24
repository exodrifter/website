---
title: Least Common Multiple
created: 2025-04-19T07:32:51Z
aliases:
- LCM
- lcm
- Least Common Multiple
- least common multiple
tags:
- competitive-programming
- math
---

# Least Common Multiple

The **Least Common Multiple**, or **LCM**, is the smallest positive integer that is divisible by two numbers. It is often included in the standard libraries for programming languages. [^1]

# Solution for two or more numbers

LCM can also be used to find the smallest positive integer that is divisible by two or more numbers. In Haskell, this is done by: [^1]

```hs
lcmMultiple numbers = foldl lcm 1 numbers
```

[^1]: [20250419072418](../entries/20250419072418.md)
