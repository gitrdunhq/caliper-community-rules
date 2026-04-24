# Code Quality Rules

Rules that detect bugs, dead code, excessive complexity, and naming violations.

## Threat model

Poor code quality is a slow-moving vulnerability. High complexity hides bugs. Inconsistent naming causes maintenance errors. Duplicate code means bugs get fixed in one place and survive in another. These rules enforce measurable quality thresholds.

## What belongs here

- **Bug patterns** -- common logic errors, off-by-ones, type confusion
- **Complexity** -- cyclomatic/cognitive complexity thresholds
- **Duplication** -- copy-paste detection thresholds
- **Naming** -- file and directory naming conventions
- **Dead code** -- unreachable branches, unused imports

## Scanners

| Directory | Scanner | File format |
|-----------|---------|-------------|
| `semgrep/` | Semgrep | `.yaml` rules + test files |
| `complexity/` | Complexity plugin | `.json` / `.yaml` threshold configs |
| `cpd/` | CPD | `.xml` / `.yaml` detection configs |
| `ls-lint/` | ls-lint | `.ls-lint.yml` naming configs |

## Example

See `semgrep/substring-match-without-word-boundary.yaml` for a rule that catches imprecise string matching.
