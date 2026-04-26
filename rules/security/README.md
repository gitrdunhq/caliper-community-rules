# Security Rules

Rules that detect vulnerabilities, leaked secrets, injection vectors, and authorization flaws.

## Threat model

Code that ships with security defects creates liability, enables breaches, and erodes trust. These rules catch patterns that static analysis can detect deterministically -- no AI guessing, no probability scores.

## What belongs here

- **Injection** -- SQL injection, command injection, SSTI, XSS patterns
- **Secrets** -- hardcoded API keys, passwords, tokens, private keys
- **Auth/authz** -- missing permission checks, broken access control patterns
- **Crypto** -- weak algorithms, hardcoded IVs, insecure random
- **Input validation** -- missing sanitization, unsafe deserialization

## Scanners

| Directory | Scanner | File format |
|-----------|---------|-------------|
| `semgrep/` | Semgrep | `.yaml` rules + test files |
| `bandit/` | Bandit | `.yaml` profile + config |
| `gitleaks/` | Gitleaks | `.toml` custom patterns |
| `opa/` | OPA | `.rego` policies + `_test.rego` |

## Example

See `semgrep/missing-oserror-on-file-open.yaml` for a rule that catches file operations without proper error handling.
