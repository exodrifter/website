# exodrifter's website

This is the repository for my personal website, which is a collection of blog
posts and notes turned into a static site with the help of Quartz and Nix.

# development

You can use ghcid to build and run the website:

```sh
ghcid --target=site --run --setup=":set args --prune --lint server"
```

# feedback

Feedback is welcome via issues, but for copyright reasons I will not accept any
pull requests.
