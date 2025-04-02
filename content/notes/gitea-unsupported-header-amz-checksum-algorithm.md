---
title: "Unsupported header `x-amz-checksum-algorithm` received for this API call."
created: 2024-08-05T23:01:41Z
modified: 2024-09-19T04:26:37Z
aliases:
- "Unsupported header `x-amz-checksum-algorithm` received for this API call."
tags:
- backblaze
- gitea
---

# Unsupported header `x-amz-checksum-algorithm` received for this API call.

If object storage is configured for Gitea, you may get the following error when trying to upload attachments:

```
NewAttachment: Create: Unsupported header 'x-amz-checksum-algorithm' received for this API call.
```

This happens because some object storage services like Backblaze and Cloudflare don't support the `x-amz-checksum-algorithm` header that Gitea is sending. There's a configuration value to change Gitea to use the legacy `md5` behavior that these services expect:

> [Gitea Documentation](https://docs.gitea.com/administration/config-cheat-sheet):
> 
> `MINIO_CHECKSUM_ALGORITHM`: **default**: Minio checksum algorithm: `default` (for MinIO or AWS S3) or `md5` (for Cloudflare or Backblaze)

Setting `MINIO_CHECKSUM_ALGORITHM` in the configuration to `md5` should fix the error.

# History

- [20240805221730](../entries/20240805221730.md)
