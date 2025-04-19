---
title: Harmonic Number
created: 2025-04-19T07:18:47Z
aliases:
- Harmonic Number
- harmonic number
tags:
- math
---

# Harmonic Number

The $n$-th harmonic number $H_n$ is: [^1]

$$
H_n = 1 + \frac 1 2 + \frac 1 3 + ... + \frac 1 n = \sum_{k=1}^n \frac 1 k
$$

In Haskell: [^1]

```hs
harmonicNumber n = sum [ 1.0 / (fromIntegral k) | k <- [1..n] ]
```

[^1]: [20250419063935](../entries/20250419063935.md)
