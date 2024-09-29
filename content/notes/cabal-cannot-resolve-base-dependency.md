---
title: Cabal cannot resolve base dependency
created: 2024-10-06T04:28:33Z
aliases:
- Cabal cannot resolve base dependency
tags:
- haskell
---

# Cabal cannot resolve base dependency

When compiling a project with `cabal`, you might find that the `base` package cannot be resolved:

```
$ cabal run
Resolving dependencies...
Error: cabal: Could not resolve dependencies:
[__0] trying: catbox-0.1.0.0 (user goal)
[__1] next goal: base (dependency of catbox)
[__1] rejecting: base-4.17.2.1/installed-4.17.2.1 (conflict: catbox =>
base>=4.14 && <4.17)
[__1] skipping: base-4.20.0.1, base-4.20.0.0, base-4.19.1.0, base-4.19.0.0,
base-4.18.2.1, base-4.18.2.0, base-4.18.1.0, base-4.18.0.0, base-4.17.2.1,
base-4.17.2.0, base-4.17.1.0, base-4.17.0.0 (has the same characteristics that
caused the previous version to fail: excluded by constraint '>=4.14 && <4.17'
from 'catbox')
[__1] rejecting: base-4.16.4.0, base-4.16.3.0, base-4.16.2.0, base-4.16.1.0,
base-4.16.0.0, base-4.15.1.0, base-4.15.0.0, base-4.14.3.0, base-4.14.2.0,
base-4.14.1.0, base-4.14.0.0, base-4.13.0.0, base-4.12.0.0, base-4.11.1.0,
base-4.11.0.0, base-4.10.1.0, base-4.10.0.0, base-4.9.1.0, base-4.9.0.0,
base-4.8.2.0, base-4.8.1.0, base-4.8.0.0, base-4.7.0.2, base-4.7.0.1,
base-4.7.0.0, base-4.6.0.1, base-4.6.0.0, base-4.5.1.0, base-4.5.0.0,
base-4.4.1.0, base-4.4.0.0, base-4.3.1.0, base-4.3.0.0, base-4.2.0.2,
base-4.2.0.1, base-4.2.0.0, base-4.1.0.0, base-4.0.0.0, base-3.0.3.2,
base-3.0.3.1 (constraint from non-upgradeable package requires installed
instance)
[__1] fail (backjumping, conflict set: base, catbox)
After searching the rest of the dependency tree exhaustively, these were the
goals I've had most trouble fulfilling: base, catbox
```

Unlike with other dependencies, `cabal` can't simply install any version of `base` on demand because it is tied to your GHC version. In order for the compilation to work, you need to either require the right version of base or change the version of GHC installed on your system. [^1]

[^1]: [20240928193630](../entries/20240928193630.md)
