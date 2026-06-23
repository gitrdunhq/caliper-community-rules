# Caliper Community Rules

Community-contributed rules and configurations for [caliper](https://github.com/gitrdunhq/caliper) -- the deterministic code review scanner with 19 plugins and zero LLM.

## What is Caliper?

Caliper is a deterministic code review tool that runs 19 specialized plugins across your codebase. No LLM. No AI. Every finding is reproducible and deterministic.

| Plugin | Category | What it does |
|--------|----------|-------------|
| Syft | Supply Chain | SBOM generation (CycloneDX, 18 ecosystems) |
| OSV-Scanner | Supply Chain | Known-vulnerability database checks (CVE/GHSA) |
| Trivy | Supply Chain | Container and IaC vulnerability scanning |
| ScanCode | Supply Chain | License detection (SPDX) |
| Supply Chain | Supply Chain | Unpinned deps + lockfile integrity + latest-tag detection |
| Semgrep | Security, Code Quality, Standards | Custom AST pattern matching |
| Gitleaks | Security | Secret and credential detection |
| ClamAV | Security | Malware signature scanning |
| Blast Radius | Standards | AST→SQLite code graph (dependency-impact checks) |
| PMD CPD | Code Quality | Copy-paste (duplicate code) detection |
| Complexity (Lizard + Radon) | Code Quality | Cyclomatic complexity + maintainability index |
| Mypy | Code Quality | Cross-file Python type checking |
| SwiftLint | Code Quality | Swift style + code smells |
| SwiftFormat | Code Quality | Swift formatting lint |
| ls-lint | Code Quality | Filename and directory naming conventions |
| typos | Content | Source-aware typo detection (crate-ci/typos) |
| kube-linter | Infrastructure | Kubernetes/Helm manifest linting |
| CDK Nag | Infrastructure | CDK CloudFormation security scanning |
| cfn-nag | Infrastructure | CloudFormation template security scanning |

All 19 feed a 20th **OPA** policy plugin (Rego) that runs last and makes the deterministic accept/reject decision.

## What is this repo?

This repository contains **community-contributed rules, configs, and policies** that extend caliper's built-in checks. Think of it as a shared library of battle-tested patterns that any team can adopt.

## How to use

### Option 1: Point Caliper at this repo

```bash
caliper scan --rules-repo caliper-community-rules/ ./your-project
```

### Option 2: Copy individual rules

Browse the category directories, find rules that fit your stack, and copy them into your project's caliper configuration.

### Option 3: Cherry-pick by category

```bash
cp -r caliper-community-rules/rules/security/  .caliper/rules/security/
cp -r caliper-community-rules/rules/supply-chain/ .caliper/rules/supply-chain/
```

## Directory structure

Rules are organized by **what they protect against**, not which scanner runs them:

```
rules/
  security/             -- Vulnerabilities, secrets, injection, auth
    semgrep/
    gitleaks/
    opa/
  supply-chain/         -- Dependency risks, license compliance, SBOM
    osv/
    trivy/
    scancode/
  code-quality/         -- Bugs, dead code, complexity, naming
    semgrep/
    complexity/
    cpd/
    ls-lint/
  infrastructure/       -- Kubernetes, Docker, IaC
    kube-linter/
    clamav/
  standards/            -- Coding standards, SOLID, DRY, FIRST
    semgrep/
    blast-radius/
    coding-standards/
  content/              -- Spelling, docs, i18n
    cspell/
```

Each category has its own README explaining the threat model and what kinds of rules belong there.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines. PRs welcome.

## License

[Apache 2.0](LICENSE)
