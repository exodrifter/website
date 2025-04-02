---
title: "Unsupported header 'x-amz-checksum-crc32' received for this API call."
created: 2025-04-02T09:48:12Z
aliases:
- "Unsupported header 'x-amz-checksum-crc32' received for this API call."
tags:
- backblaze
- discourse
---

# Unsupported header 'x-amz-checksum-crc32' received for this API call.

While updating Discourse after Feb 24th, the update might fail with the following error message if you use Backblaze or some other S3 provider that isn't AWS: [^1]

```
I, [2025-04-02T08:51:34.524786 #1]  INFO -- : > cd /var/www/discourse && sudo -E -u discourse bundle exec rake s3:upload_assets
`/root` is not writable.
Bundler will use `/tmp/bundler20250402-1714-yuyf6i1714' as your home directory temporarily.
rake aborted!
Aws::S3::Errors::InvalidArgument: Unsupported header 'x-amz-checksum-crc32' received for this API call. (Aws::S3::Errors::InvalidArgument)
```

This is because of a breaking change in the AWS SDK that has been reported, [but was closed as "not planned"](https://github.com/aws/aws-sdk-js-v3/issues/6819). The workaround is to update the environment and remove the `expire_missing_assets` step: [^1]

```yml
env:
  AWS_REQUEST_CHECKSUM_CALCULATION: WHEN_REQUIRED
  AWS_RESPONSE_CHECKSUM_VALIDATION: WHEN_REQUIRED
  ## elided

## elided

hooks:
  ## elided  
  after_assets_precompile:
    - exec:
        cd: $home
        cmd:
          - sudo -E -u discourse bundle exec rake s3:upload_assets
##        - sudo -E -u discourse bundle exec rake s3:expire_missing_assets
```

This workaround will result in assets not being deleted from the bucket anymore. [^1]

[^1]: [20250402091023](../entries/20250402091023.md)
