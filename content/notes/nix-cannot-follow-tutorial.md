---
title: Cannot follow Nix tutorial
alias:
- Cannot follow Nix tutorial
tags:
- nix
---

# Cannot follow Nix tutorial

When you try to run the [nix.dev tutorial](https://nix.dev/tutorials/first-steps/ad-hoc-shell-environments), you may find that the `nix-shell -p cowsay lolcat` command doesn't work as expected. There are a few potential reasons for why this happens:

**Nix is unable to find `nixpkgs`.** Fix this by installing a channel:

```sh
nix-channel --add https://nixos.org/channels/nixpkgs-unstable
nix-channel --update
```

**The shell cannot find cowsay or lolcat.** This may be because you have a `.bashrc` or `.bash_profile` script which modifies the `PATH` in some way that prevents `nix` from modifying it as expected. You also might have a line that launches another shell, like `exec fish` which causes this problem.

## History

![20240812075541](../entries/20240812075541.md)
