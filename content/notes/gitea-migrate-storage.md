---
title: "How do I migrate Gitea storage?"
aliases:
- "How do I migrate Gitea storage?"
---

# How do I migrate Gitea storage?

To migrate Gitea storage from one type of storage to another, the `migrate-storage` command can be used. For example, to migrate from the storage currently configured in the `app.ini` to Minio:

```sh
for DATATYPE in attachments lfs avatars repo-avatars repo-archive packages actions-log actions-artifacts; do
    echo DATATYPE=$DATATYPE;
	gitea migrate-storage \
        --type=$DATATYPE \
        --minio-base-path=$DATATYPE \
        --storage=minio \
        --minio-endpoint=$MINIO_ENDPOINT \
        --minio-access-key-id=$MINIO_ACCESS_KEY_ID \
        --minio-secret-access-key=$MINIO_SECRET_ACCESS_KEY \
        --minio-bucket=$MINIO_BUCKET \
        --minio-location=$MINIO_LOCATION \
        --minio-use-ssl=true
done
```

You may have to rename the `actions-log` and `actions-artifacts` to `actions_log` and `actions_artifacts` respectively depending on how your paths are configured in Gitea.

## History

![20240803_164302](../entries/20240803_164302.md)
