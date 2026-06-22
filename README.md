# Caliper Community Rules

Community-contributed rules and configurations for [caliper](https://github.com/gitrdunhq/caliper) -- the deterministic code review scanner with 15 plugins and zero LLM.

## What is Caliper?

Caliper is a deterministic code review tool that runs 15 specialized plugins across your codebase. No LLM. No AI. Every finding is reproducible and deterministic.

| Plugin | Category | What it does |
|--------|----------|-------------|
| Semgrep | Security, Code Quality, Standards | Custom pattern matching |
| OPA | Security | Policy-as-code checks (Rego) |
| cspell | Content | Spell checking with custom dictionaries |
| Blast Radius | Standards | SQL graph analysis (dependency impact) |
| kube-linter | Infrastructure | Kubernetes manifest linting |
| Supply Chain | Supply Chain | Dependency policy enforcement |
| Coding Standards | Standards | SOLID/FIRST/DRY checks |
| Complexity | Code Quality | Cyclomatic/cognitive complexity thresholds |
| ClamAV | Infrastructure | Malware signature scanning |
| Gitleaks | Security | Secret and credential detection |
| Trivy | Supply Chain | Container and IaC vulnerability scanning |
| OSV | Supply Chain | Open Source Vulnerability database checks |
| ScanCode | Supply Chain | License compliance scanning |
| ls-lint | Code Quality | Filename and directory naming conventions |
| CPD | Code Quality | Copy-paste (duplicate code) detection |

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
