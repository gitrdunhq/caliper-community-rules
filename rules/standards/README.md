# Coding Standards Rules

Rules that enforce SOLID principles, DRY, FIRST test quality, and architectural boundaries.

## Threat model

Standards drift is invisible until it isn't. When coding conventions are enforced by humans alone, they decay. These rules make standards machine-checkable -- every PR gets the same review regardless of who submits it or who reviews it.

## What belongs here

- **SOLID violations** -- god classes, deep inheritance, interface segregation breaches
- **DRY violations** -- exact and near-duplicate logic across modules
- **Naming conventions** -- inconsistent enum/constant/event-type naming
- **Architectural boundaries** -- layer violations, circular dependencies
- **Dependency graph** -- blast radius analysis for high-impact changes

## Scanners

| Directory | Scanner | File format |
|-----------|---------|-------------|
| `semgrep/` | Semgrep | `.yaml` rules + test files |
| `blast-radius/` | Blast Radius | `.py` / `.sql` graph scripts |
| `coding-standards/` | Coding Standards plugin | `.yaml` / `.json` configs |

## Example

See `semgrep/event-type-string-consistency.yaml` for a rule that catches hardcoded event type strings that should use enums.
