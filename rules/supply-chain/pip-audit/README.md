# pip-audit Rules

Configuration and examples for the caliper [pip-audit](https://github.com/pypa/pip-audit) plugin. pip-audit scans Python environments and dependency files for packages with known vulnerabilities using the [OSV](https://osv.dev/) database and PyPI's vulnerability API.

## What pip-audit catches

- **Known CVEs** in installed Python packages
- **GHSA advisories** (GitHub Security Advisories) mapped to Python packages
- **PyPI vulnerability reports** from the PyPI JSON API
- Vulnerabilities across `requirements.txt`, `pyproject.toml`, `Pipfile.lock`, and installed environments

## How Caliper integrates it

The caliper pip-audit plugin runs `pip-audit --format=json` as a subprocess, parses the structured output, and maps each finding to an caliper severity level based on CVSS score and fix availability.

### Severity mapping

| Fix Available | CVSS Score | caliper Severity |
|---------------|------------|----------------|
| Yes | 9.0+ | critical |
| Yes | 7.0--8.9 | high |
| Yes | 4.0--6.9 | warning |
| No | 9.0+ | critical |
| No | 7.0--8.9 | high |
| No | 4.0--6.9 | warning |
| * | 0--3.9 | info |

Fix availability does not downgrade severity -- a critical vulnerability is critical whether or not a patch exists. The distinction matters for **triage priority**: findings with available fixes get actionable upgrade recommendations in PR comments.

## Triage workflow

1. **pip-audit finds a vulnerable dependency.** The plugin parses JSON output and extracts package name, installed version, fixed version (if any), vulnerability ID, and CVSS score.
2. **caliper maps to severity** using the table above (CVSS score + fix availability).
3. **If a fix is available**, the PR comment includes an actionable recommendation: "Upgrade `package` from `X.Y.Z` to `A.B.C` to resolve `VULN-ID`."
4. **If no fix is available**, caliper checks the allowlist:
   - If the vulnerability is allowlisted with a valid (non-expired) entry, the finding is suppressed.
   - If not allowlisted, the finding is reported normally.
5. **Expired allowlist entries** auto-escalate to `warning` severity regardless of original severity, signaling that the exemption needs re-evaluation.

## How it differs from alternatives

| Tool | Scope | Data source | Status |
|------|-------|-------------|--------|
| **pip-audit** | Python packages only | OSV + PyPI | Active, maintained by PyPA |
| **safety** | Python packages only | SafetyCLI database | Commercial (free tier limited since 2023) |
| **osv-scanner** | All ecosystems | OSV | Broader scope, not Python-specific |

pip-audit is the best fit for Python-focused scanning: it understands Python packaging natively (virtualenvs, lockfiles, editable installs), it uses the same OSV database as osv-scanner but with Python-specific resolution, and it remains fully open source under the Apache 2.0 license.

## Included files

| File | What it does |
|------|-------------|
| `pip-audit.config.yaml` | caliper plugin configuration -- severity mapping, sources, timeouts |
| `allowlist-example.yaml` | Example allowlist for suppressing known acceptable vulnerabilities |

## References

- [pypa/pip-audit on GitHub](https://github.com/pypa/pip-audit)
- [OSV database](https://osv.dev/)
- [PyPI vulnerability API](https://warehouse.pypa.io/api-reference/json.html)
