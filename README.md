step-s3-website
===============

Wercker step to deploy static websites to S3/Cloudfront using s3_website

## Usage

```yaml
deploy:
  steps:
    - s3-website:
      key: $KEY
      secret: $SECRET
      bucket: $BUCKET
```
