# caliper-community-rules (codename: Kirby)

This repo is the community scanner rule catalog for **caliper** — a deterministic code review tool. Kirby ships rules that caliper applies during PR review, CI gates, and fleet-wide scans. Rules are the product here: they must be correct, well-tested, and accurately mapped to compliance controls.

## What lives here

Scanner rules organized by category and plugin type:

```
rules/
  security/
    semgrep/          # Semgrep YAML rules for code-level vulnerabilities
    bandit/           # Bandit rules for Python-specific issues
    gitleaks/         # Gitleaks rules for secret detection
    opa/              # OPA/Rego rules for policy enforcement
  infrastructure/
    tfsec/            # tfsec custom check JSON for Terraform
    cfn-nag/          # cfn-nag Ruby rules for CloudFormation
    kube-linter/      # kube-linter YAML for Kubernetes manifests
    cdk-nag/          # CDK Nag rules for AWS CDK
    dockerfile-semgrep/  # Semgrep YAML rules targeting Dockerfiles
  code-quality/
  standards/
  supply-chain/
  content/
```

Supporting catalog files at the repo root:
- `kirby-rule-schema.yaml` — canonical schema for all rule metadata
- `compliance-catalog.yaml` — maps every kirby_id to compliance control IDs

## Rule identity

Every rule carries a **KIRBY-{CAT}-{NNN}** ID:

| Prefix | Category |
|--------|----------|
| KIRBY-SEC | security |
| KIRBY-INF | infrastructure |
| KIRBY-SCM | supply-chain |
| KIRBY-QUA | code-quality |
| KIRBY-STD | standards |
| KIRBY-CON | content |

IDs are sequential and never reused. The next available ID for a category is determined by scanning `compliance-catalog.yaml`.

## Metadata every rule must carry

Regardless of scanner format, each rule must embed (or have a sidecar entry in `compliance-catalog.yaml` for):

| Field | Description |
|-------|-------------|
| `kirby_id` | Canonical KIRBY-{CAT}-{NNN} identifier |
| `category` | Top-level category (security, infrastructure, etc.) |
| `subcategory` | Specific vulnerability class (command-injection, s3-public-access, etc.) |
| `property_domain` | DPS-12 property domain the rule validates |
| `caliper-plugin` | Scanner that executes this rule (semgrep, tfsec, cfn-nag, kube-linter, etc.) |
| `compliance_mappings` | Array of {framework, controls[]} entries |
| `references` | URLs to authoritative docs for the underlying control |

### Property domains (DPS-12)

```
integrity  confidentiality  availability  determinism  uniqueness
non-repudiation  idempotency  atomicity  monotonicity  ordering
isolation  boundedness  linearity  reversibility
```

Pick the domain that best describes what the rule enforces.

## Compliance frameworks

The catalog maps rules to controls in 15+ frameworks. Use the exact framework IDs and control IDs from `compliance-catalog.yaml` and `kirby-rule-schema.yaml`:

```
nist-800-53-r5    cis-aws-v2.0      cis-k8s-v1.7
cis-docker-v1.6   cis-azure-v2.0    cis-gcp-v2.0
owasp-top10-2021  owasp-asvs-v4.0   pci-dss-v4.0
hipaa-security    iso-27001-2022     soc2-tsc
fedramp-moderate  disa-stig          aws-config
```

## Test fixtures are required

Every rule must ship with test fixtures covering both positive and negative cases:
- Positive case: code that SHOULD trigger the rule (true positive)
- Negative case: code that should NOT trigger the rule (true negative)

Fixtures live in a `tests/` directory alongside the rule file. Naming:
- Semgrep: `tests/{rule-id}_test.{ext}` with `# ruleid: {rule-id}` / `# ok: {rule-id}` annotations
- tfsec: `tests/` and `test-fixtures/` with PASS/FAIL Terraform blocks
- kube-linter: `tests/` with passing and failing YAML manifests

## Pattern quality is the only thing that matters

**False positives** erode trust — developers start ignoring caliper findings. Every pattern must be tight enough to avoid flagging correct code.

**False negatives** leave gaps — vulnerabilities the rule claims to catch slip through. Common variants (different APIs, different string construction methods, equivalent idioms) must be covered.

When in doubt, review comparable patterns in the existing rules before adding a new one.
