---
title: Coupon Collector's Problem
created: 2025-04-19T07:07:10Z
aliases:
- Coupon Collector's Problem
- coupon collector's problem
tags:
- math
---

# Coupon Collector's Problem

The **Coupon Collector's Problem** is about how many draws it is expected to take in order to collect all coupons by random draw. [^1]

# Solution

The solution to the problem is $n * H_n$, where $n$ is the number of coupons to collect and $H_n$ is the $n$-th [harmonic number](harmonic-number.md): [^1]

$$
n * \sum_{k=1}^n \frac 1 k
$$

In Haskell: [^1]

```hs
expected :: Int -> Float
expected n =
  fromIntegral n * sum [ 1.0 / (fromIntegral k) | k <- [1..n] ]
```

[^1]: [20250419063935](../entries/20250419063935.md)
