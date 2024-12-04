---
title: Update a backup of a Borg repo
created: 2024-12-04T09:03:59Z
aliases:
- Update a backup of a Borg repo
tags:
- borg
---

# Update a backup of a Borg repo

A backup of a Borg repo can be made with the following command: [^1]

```sh
cd /run/media/exodrifter/Backup/
borg extract --list <repo_url>::<archive_name>
```

However, `borg extract` will copy over all of the files, even if they already exist. To only copy over the changes, the repo can be mounted using `borg mount` and then the changes copied over using `rsync`. [^1]

First, FUSE support needs to be installed. On Arch Linux, this is done with: [^1]

```sh
pacman -S python-llfuse
```

Then the archive can be mounted and browsed with: [^1]

```sh
mkdir /mnt/borg
borg mount <repo_url>::<archive_name> /mnt/borg
rsync --progress --archive --delete /mnt/borg/sky-2024-12-04T08:32:06.701926/mnt/data/sync/ /run/media/exodrifter/Backup/mnt/data/sync
```

[^1]: [20241203214204](../entries/20241203214204.md)
