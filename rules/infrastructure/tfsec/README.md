# tfsec — Terraform Static Analysis

tfsec is a static analysis security scanner for Terraform code. It detects misconfigurations across AWS, Azure, GCP, and other providers — unencrypted storage, overly permissive IAM, missing logging, public-facing resources, and more.

tfsec has been absorbed into [Trivy](https://github.com/aquasecurity/trivy) as the Terraform misconfiguration scanner. caliper supports both: **tfsec** for standalone Terraform scanning, **Trivy** for broader infrastructure scanning that includes container images and filesystems alongside IaC.

## What tfsec catches

- **AWS**: Unencrypted S3 buckets, public security groups, missing CloudTrail logging, overly permissive IAM policies, unencrypted RDS/EBS/EFS, missing VPC flow logs
- **Azure**: Unencrypted storage accounts, public network access, missing diagnostic settings, overly permissive NSG rules
- **GCP**: Public Cloud Storage buckets, missing audit logging, overly permissive firewall rules, unencrypted disks
- **General**: Missing encryption at rest and in transit, missing access logging, overly broad CIDR blocks, hardcoded credentials

350+ built-in rules across all major cloud providers.

## How Caliper integrates tfsec

Caliper runs `tfsec` as a subprocess with JSON output, parses the results, and maps each finding to caliper's severity model. Custom rules (the `.json` files in this directory) are passed via `--custom-check-dir`.

```
tfsec <path> --format json --custom-check-dir <this-dir> --force-all-dirs
```

### Severity mapping

| tfsec Severity | caliper Severity |
|----------------|----------------|
| CRITICAL       | critical       |
| HIGH           | high           |
| MEDIUM         | warning        |
| LOW            | info           |

## Custom rules in this directory

| File | Code | What it enforces |
|------|------|------------------|
| `custom-s3-versioning.json` | CALIPER-AWS-001 | S3 buckets must have versioning enabled |
| `custom-rds-backup.json` | CALIPER-AWS-002 | RDS backup retention must be >= 7 days |
| `custom-cloudwatch-log-retention.json` | CALIPER-AWS-003 | CloudWatch log groups must set retention policy |

## Configuration

See `tfsec.config.yaml` for the caliper plugin configuration (place in `.caliper/tfsec.config.yaml` in your repo).

## Test fixtures

The `test-fixtures/` directory contains example Terraform files:
- `pass.tf` — passes all custom checks
- `fail.tf` — fails all custom checks

## References

- [tfsec on GitHub](https://github.com/aquasecurity/tfsec)
- [tfsec custom checks documentation](https://aquasecurity.github.io/tfsec/latest/guides/configuration/custom-checks/)
- [Trivy misconfiguration scanning](https://aquasecurity.github.io/trivy/latest/docs/scanner/misconfiguration/)
