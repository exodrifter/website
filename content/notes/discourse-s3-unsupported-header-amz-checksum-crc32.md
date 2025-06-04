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

This is because of a breaking change in the AWS SDK that has been reported, [but was closed as "not planned"](https://github.com/aws/aws-sdk-js-v3/issues/6819). The workaround is to tell the Discourse installation to use the last compatible version of the AWS SDK. First, create `templates/aws-revert.template.yml`: [^2]

```
# Revert aws-sdk-s3 to a version that works with Backblaze
hooks:
  after_bundle_exec:
    - exec:
        cd: $home
        cmd:
          - bundle config set frozen false
          - "sed -i 's/gem \"aws-sdk-s3\", require: false/gem \"aws-sdk-s3\", \"1.177.0\", require: false/' Gemfile"
          - bundle update aws-sdk-s3
          - bundle add aws-sdk-core --version 3.215
```

Then include the template in `app.yml`: [^2]

```
templates:
  - "templates/aws-revert.template.yml"
```

[^1]: [20250402091023](../entries/20250402091023.md)
[^2]: [20250604052045](../entries/20250604052045.md)
