---
title: Preferred Git config
created: 2025-05-04T00:40:48Z
aliases:
- Preferred Git config
tags:
- git
---

# Preferred Git config

This is my preferred configuration for Git: [^1]

```
[filter "lfs"]
	required = true
	clean = git-lfs clean -- %f
	smudge = git-lfs smudge -- %f
	process = git-lfs filter-process
[init]
	defaultBranch = main
[core]
	editor = nvim
[push]
	autoSetupRemote = true
	followTags = true
[branch]
	sort = -committerdate
[tag]
	sort = version:refname
[diff]
	algorithm = histogram
	colorMoved = plain
	mnemonicPrefix = true
	renames = true
[fetch]
	prune = true
	pruneTags = true
	all = true
[commit]
	verbose = true
```

From a fresh install: [^1]

```sh
git lfs install
git config --global init.defaultBranch main
git config --global core.editor nvim
git config --global branch.sort -committerdate
git config --global tag.sort version:refname
git config --global diff.algorithm histogram
git config --global diff.colorMoved plain
git config --global diff.mnemonicPrefix true
git config --global diff.renames true
git config --global push.autoSetupRemote true
git config --global push.followTags true
git config --global fetch.prune true
git config --global fetch.pruneTags true
git config --global fetch.all true
git config --global commit.verbose true
```

[^1]: [20250504243105](../entries/20250504243105.md)
