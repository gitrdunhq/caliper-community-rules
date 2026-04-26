# Supply Chain Rules

Rules that detect dependency risks, license violations, and vulnerable components.

## Threat model

Your code is only as secure as its weakest dependency. Supply chain attacks (typosquatting, compromised maintainers, abandoned packages) are the fastest-growing attack vector. These rules enforce policy on what enters your dependency tree.

## What belongs here

- **Known vulnerabilities** -- CVE/GHSA detection overrides and custom policies
- **License compliance** -- forbidden licenses, copyleft in proprietary code
- **Dependency hygiene** -- pinning policies, age requirements, maintainer trust signals
- **SBOM validation** -- completeness checks on software bill of materials

## Scanners

| Directory | Scanner | File format |
|-----------|---------|-------------|
| `pip-audit/` | pip-audit | `.yaml` config + allowlists |
| `osv/` | OSV-Scanner | `.json` override configs |
| `trivy/` | Trivy | `.yaml` ignore/policy files |
| `scancode/` | ScanCode | `.json` license policy configs |
