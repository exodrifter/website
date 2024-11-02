---
title: Run PHP web server with Nix
created: 2024-11-02T07:47:22Z
aliases:
- Run PHP web server with Nix
tags:
- nix
- php
---

# Run PHP web server with Nix

To run a PHP server for testing purposes with Nix, run the following command: [^1]

```
cd path/to/website/
nix shell nixpkgs#php
php -S localhost:8000
```

[^1]: [20241102074216](../entries/20241102074216.md)
