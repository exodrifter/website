---
title: Borg failed to acquire lock
created: 2024-12-04T08:59:38Z
aliases:
- Borg failed to acquire lock
tags:
- borg
---

# Borg failed to acquire lock

If a previous backup had been interrupted for some reason, a borg backup can fail with the following error: [^1]

```
/etc/borgmatic.d/sync.yaml: An error occurred
borgbase: Error running actions for repository
Failed to create/acquire the lock /srv/repos/<name>/repo/lock.exclusive (timeout).
Command 'borg create --info <repo>::{hostname}-{now:%Y-%m-%dT%H:%M:%S.%f} /etc/borgmatic.d/immich.yaml /etc/borgmatic.d/sync.yaml /mnt/data/sync /run/user/0/./borgmatic' returned non-zero exit status 73.

Need some help? https://torsion.org/borgmatic/#issues
```

First, ensure that nothing is currently doing a backup. Then, remove the lock using `borg break-lock <repo>`. [^1]

[^1]: [20241204085240](../entries/20241204085240.md)