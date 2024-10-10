---
title: Nix cannot find file
created: 2024-10-10T20:30:25Z
aliases:
- Nix cannot find file
tags:
- nix
---

# Nix cannot find file

While trying to use Nix flakes, you might get an error that looks like this: [^1]

```
warning: Git tree '/home/exodrifter/notes/logbook' is dirty
error (ignored): error: end of string reached
error:
       … while calling the 'derivationStrict' builtin
         at <nix/derivation-internal.nix>:9:12:
            8|
            9|   strict = derivationStrict drvAttrs;
             |            ^
           10|

       … while evaluating derivation 'quartz-4.3.1'
         whose name attribute is located at /nix/store/wzx1ba5hqqfa23vfrvqmfmkpj25p37mr-source/pkgs/stdenv/generic/make-derivation.nix:331:7

       … while evaluating attribute 'installPhase' of derivation 'quartz-4.3.1'
         at /nix/store/bkm5f4jk8c8w7zg4iav1vv2xrxvisv9r-source/flake.nix:36:15:
           35|
           36|               installPhase = ''
             |               ^
           37|                 runHook preInstall

       error: path '/nix/store/bkm5f4jk8c8w7zg4iav1vv2xrxvisv9r-source/quartz.layout.ts' does not exist
```

Nix errors contain the most relevant error at the bottom; here, we can see that it cannot find the file `quartz.layout.ts`. In this example, the file `quartz.layout.ts` _does_ exist, but files that are not tracked by the git repository are not copied to the Nix store by the Nix flake. Tracking the file (such as `git add quartz.layout.ts` for example), then the Nix error will go away. [^1]

[^1]: [20240916000936](../entries/20240916000936.md)
