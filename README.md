# exodrifter's website

This is the repository for my personal website, which is a collection of blog
posts and notes turned into a static site with the help of Quartz and Nix.

# development

You can use standard Nix commands to build and run the website:

```sh
nix build # Just to build
nix run # Build and run a test Caddy server at port 8080
```

The resulting website will be at the path `result/public`.

# feedback

Feedback is welcome via issues, but for copyright reasons I will not accept any
pull requests.
