# cfn-nag Rules

CloudFormation security rules for the eedom `cfn-nag` plugin. These are [cfn_nag custom rules](https://github.com/stelligent/cfn_nag#custom-rules) that extend the built-in checks.

## How to use

Place `.rb` rule files in your repo's `.eedom/cfn-nag-rules/` directory. The eedom cfn-nag plugin picks them up automatically via `--rule-directory`.

## Included rules

| Rule | What it catches | Severity |
|------|----------------|----------|
| `iam_wildcard_resource.rb` | IAM policies with `Resource: "*"` | FAIL (critical) |
| `s3_public_access.rb` | S3 buckets without PublicAccessBlockConfiguration | FAIL (critical) |
| `rds_unencrypted.rb` | RDS instances without StorageEncrypted | FAIL (critical) |
