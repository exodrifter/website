# exodrifter's website

This is the repository for my personal website, which is a collection of blog
posts and notes turned into a static site with the help of Quartz and Nix.

# development

You can use ghcid to continuously build and run the website:

```sh
ghcid --target=site --run --setup=":set args --prune --lint server"
```

Unfortunately, it does not detect changes to input files automatically because
shake does not have filewatch. Instead, you have to run the command again.

# build

To build the website, run:

```sh
cabal run site -- --prune --lint
```

The generated website will be in the directory `_site`.

# feedback

Feedback is welcome via issues, but for copyright reasons I will not accept any
pull requests.
