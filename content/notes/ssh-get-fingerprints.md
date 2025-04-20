---
title: Get SSH fingerprints
created: 2025-04-20T19:48:17Z
aliases:
- Get SSH fingerprints
tags:
- ssh
---

# Get SSH fingerprints

To get the SSH fingerprint of the local machine or a remote one, run the following command: [^1]

```sh
ssh-keyscan localhost | ssh-keygen -lf -
```

`localhost` can be changed to any other IP address or URL. The output will look something like this: [^1]

```
3072 SHA256:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX localhost (RSA)
256 SHA256:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX localhost (ECDSA)
256 SHA256:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX localhost (ED25519)
```

[^1]: [20250420194410](../entries/20250420194410.md)
