---
description: 'Conventions for tfsec custom check JSON files'
applyTo: 'rules/**/tfsec/*.json'
---

# tfsec Custom Check Conventions

tfsec checks in this repo run via the caliper `tfsec` plugin. Every check is a JSON file under `rules/{category}/tfsec/` named `{check-name}_tfchecks.json`. The `_tfchecks.json` suffix is required by tfsec's custom check loader.

## File structure

```json
{
  "_kirby": {
    "kirby_id": "KIRBY-INF-NNN",
    "property_domain": "availability",
    "compliance_mappings": [
      {"framework": "nist-800-53-r5", "controls": ["CP-9", "CP-10"]},
      {"framework": "soc2-tsc",       "controls": ["A1.2"]},
      {"framework": "aws-config",     "controls": ["S3_BUCKET_VERSIONING_ENABLED"]}
    ]
  },
  "checks": [
    {
      "code": "CALIPER-AWS-NNN",
      "description": "Short human-readable description of what this check enforces",
      "impact": "What goes wrong if this check fails in production",
      "resolution": "Exact Terraform resource and attribute to set",
      "requiredTypes": ["resource"],
      "requiredLabels": ["aws_s3_bucket_versioning"],
      "severity": "HIGH",
      "matchSpec": { ... },
      "errorMessage": "Specific message shown when the check fails"
    }
  ]
}
```

## `_kirby` block

The `_kirby` top-level key is ignored by tfsec but parsed by caliper for compliance reporting. It is required on every file.

| Field | Description |
|-------|-------------|
| `kirby_id` | `KIRBY-{CAT}-{NNN}` — check `compliance-catalog.yaml` for the next ID |
| `property_domain` | DPS-12 domain string (e.g., `availability`, `confidentiality`) |
| `compliance_mappings` | Array of `{framework, controls[]}` using the enum values in `kirby-rule-schema.yaml` |

## `checks` array

A single `_tfchecks.json` file may contain multiple check objects when related controls logically belong together (e.g., encryption-at-rest and encryption-in-transit for the same service). When in doubt, one check per file.

### Check code prefixes

| Cloud | Prefix | Example |
|-------|--------|---------|
| AWS | `CALIPER-AWS-NNN` | `CALIPER-AWS-042` |
| Azure | `CALIPER-AZ-NNN` | `CALIPER-AZ-007` |
| GCP | `CALIPER-GCP-NNN` | `CALIPER-GCP-015` |
| Multi-cloud | `CALIPER-CLOUD-NNN` | `CALIPER-CLOUD-001` |

Codes are sequential within their prefix namespace. Check existing files to find the next available number.

### Required check fields

| Field | Description |
|-------|-------------|
| `code` | Cloud-prefixed check code (see above) |
| `description` | One sentence: what this check enforces |
| `impact` | One sentence: the real-world consequence if this fails |
| `resolution` | Specific Terraform resource type and attribute to add or change |
| `requiredTypes` | Usually `["resource"]`; use `["data"]` for data source checks |
| `requiredLabels` | Terraform resource type(s) this check applies to |
| `severity` | `CRITICAL`, `HIGH`, `MEDIUM`, `LOW` |
| `matchSpec` | The predicate tree (see below) |
| `errorMessage` | Message shown in tfsec output when the check fails |

### `severity` values

| Value | When to use |
|-------|-------------|
| `CRITICAL` | Immediate exploitation path (public S3 bucket, no encryption on PHI store) |
| `HIGH` | Misconfiguration with direct security or availability impact |
| `MEDIUM` | Missing hardening that increases attack surface |
| `LOW` | Best practice deviation with low exploitation probability |

## `matchSpec` — predicate logic

`matchSpec` defines the condition that the Terraform resource must satisfy. tfsec evaluates this against the resource's attribute tree.

### Simple attribute check

```json
"matchSpec": {
  "name": "versioning_configuration",
  "action": "isPresent",
  "subMatch": {
    "name": "status",
    "action": "equals",
    "value": "Enabled"
  }
}
```

### Available actions

| Action | Checks |
|--------|--------|
| `isPresent` | Attribute exists |
| `isAbsent` | Attribute does not exist |
| `isTrue` | Boolean attribute is `true` |
| `isFalse` | Boolean attribute is `false` |
| `equals` | Attribute equals `value` (string or number) |
| `notEquals` | Attribute does not equal `value` |
| `contains` | String/array contains `value` |
| `regexMatches` | Attribute matches regex `value` |

### Compound predicates with `and` / `or` / `not`

```json
"matchSpec": {
  "action": "and",
  "predicateMatchSpec": [
    {
      "name": "server_side_encryption_configuration",
      "action": "isPresent"
    },
    {
      "name": "rule",
      "action": "isPresent",
      "subMatch": {
        "name": "apply_server_side_encryption_by_default",
        "action": "isPresent"
      }
    }
  ]
}
```

Trace the predicate logic against your PASS and FAIL fixtures before submitting. A common mistake is using `isFalse` when the violation is absence (use `isAbsent`) or inverting `and`/`or` in compound specs.

## Test fixtures

Every tfsec check requires Terraform fixture files in a `tests/` directory (and optionally `test-fixtures/`).

### PASS fixture — resource that satisfies the check

```hcl
# tests/s3-versioning-pass.tf
resource "aws_s3_bucket_versioning" "pass" {
  bucket = aws_s3_bucket.example.id

  versioning_configuration {
    status = "Enabled"
  }
}
```

### FAIL fixture — resource that violates the check

```hcl
# tests/s3-versioning-fail.tf
resource "aws_s3_bucket" "fail" {
  bucket = "example-bucket"
  # No aws_s3_bucket_versioning resource — check fails
}
```

Fixture requirements:
- At least one PASS and one FAIL case per check
- FAIL cases must represent realistic Terraform configurations, not contrived ones
- PASS cases must be the actual remediation (not a workaround that happens to pass)

Run `tfsec --custom-check-dir rules/{category}/tfsec/ tests/` to verify locally before submitting.
