---
title: Run Haskell source files as shell scripts
created: 2024-11-21T20:13:21Z
aliases:
- Run Haskell source files as shell scripts
tags:
- cabal
- haskell
---

# Run Haskell source files as shell scripts

To run a Haskell source file as a shell script, add one of the following blocks to the top of your source file:

With `runhaskell`: [^1]

```hs
#!/usr/bin/env runhaskell
```

With `cabal`: [^1]

```hs
#!/usr/bin/env cabal
{- cabal:
build-depends: base
-}
```

With `stack`: [^2]

```hs
#!/usr/bin/env stack
-- stack script
```

Then, mark the script as executable: `chmod u+x example.hs`

[^1]: [20241121201018](../entries/20241121201018.md)
[^2]: [20241121201650](../entries/20241121201650.md)
