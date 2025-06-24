---
title: Discourse upload doesn't work
created: 2025-06-24T09:48:28Z
aliases:
- Discourse upload doesn't work
tags:
- discourse
- nginx
---

# Discourse upload doesn't work

Uploading a file smaller than the Discourse instance's "Max attachment size" might still fail if nginx is not configured correctly, which might be the case if you manage nginx manually. [^1]

By default, `client_max_body_size` is 1 MB. You'll want to update this value in the nginx config to whatever the max attachment size is:  [^1]

```diff
 server {
     root /var/www/html;

     index index.html index.htm index.nginx-debian.html;
     server_name forum.tsuki.games;
+    client_max_body_size 10M;
```

Then reload nginx: [^1]

```sh
service nginx reload
```

[^1]: [20250624094228](../entries/20250624094228.md)
