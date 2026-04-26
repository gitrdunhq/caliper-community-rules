---
description: 'Conventions for Semgrep YAML rule files'
applyTo: 'rules/**/semgrep/*.yaml'
---

# Semgrep Rule Conventions

Semgrep rules in this repo run via the eedom `semgrep` plugin. Every rule is a YAML file under `rules/{category}/semgrep/`. The filename (kebab-case, no extension) must match the rule `id`.

## Rule structure

```yaml
rules:
  - id: rule-name-in-kebab-case
    pattern-either:
      - pattern: ...
      - pattern: ...
    message: >
      What was detected. Why it is dangerous. How to fix it.
    languages: [python]
    severity: ERROR
    metadata:
      kirby_id: KIRBY-SEC-NNN
      category: security
      subcategory: vulnerability-class
      property-domain: integrity
      eedom-plugin: semgrep
      compliance_mappings:
        - framework: owasp-top10-2021
          controls: ["A03:2021"]
      references:
        - https://example.com/authoritative-source
```

## Patterns

### Use `pattern-either` for multiple variants

Never write a single narrow pattern when the vulnerability appears in multiple forms. Cover all realistic variants:

```yaml
# Good — covers all common command injection paths
pattern-either:
  - pattern: os.system(f"...")
  - pattern: os.system(f'...')
  - pattern: os.system("..." + $VAR)
  - pattern: os.popen(f"...")
  - pattern: subprocess.run(f"...", ..., shell=True)
  - pattern: subprocess.run("..." + $VAR, ..., shell=True)
```

### Use metavariables for variable input

Match the structure of the vulnerability, not a specific variable name:

```yaml
# Bad — only catches if the variable is named "user_input"
- pattern: os.system(user_input)

# Good — catches any variable passed to os.system
- pattern: os.system($INPUT)
```

### Use `metavariable-regex` for value filtering

When a pattern should only fire for specific values of a metavariable, add a `metavariable-regex` clause:

```yaml
patterns:
  - pattern: logging.basicConfig(level=$LEVEL)
  - metavariable-regex:
      metavariable: $LEVEL
      regex: '^(logging\.DEBUG|10)$'
```

Anchor regex patterns with `^...$` to prevent substring matches. Keep regexes as specific as the vulnerability requires — overly broad patterns produce false positives.

### Use `pattern-not` to exclude safe usage

When a pattern would match both safe and unsafe code, add `pattern-not` clauses to exclude the safe form:

```yaml
patterns:
  - pattern: subprocess.run($CMD, ...)
  - pattern-not: subprocess.run($CMD, ..., shell=False, ...)
  - pattern-not: subprocess.run([$CMD, ...], ...)
```

Verify that `pattern-not` clauses do not exclude attack variants. Test both positive and negative cases.

## `message` field

Write the message as a multi-sentence `>` block (folded scalar). Answer three questions:

1. What code pattern was detected?
2. Why is it a vulnerability — what can an attacker do?
3. What is the safe alternative?

```yaml
message: >
  Command injection vulnerability detected. User-controlled input is
  interpolated into a shell command string via f-string or string
  concatenation. When executed via os.system or subprocess with shell=True,
  an attacker can inject shell metacharacters to run arbitrary commands on
  the host. Use subprocess with a list of arguments and shell=False:
  subprocess.run(["cmd", user_arg]). Validate any input that must appear
  in a command invocation.
```

Do not use single-line messages. Developers read this in their PR diff — it needs context.

## `languages` field

Always explicit. Never omit. Use the Semgrep language identifier:

```
python  javascript  typescript  java  go  ruby  rust  c  cpp
bash    yaml        json        hcl   dockerfile
```

## `severity` field

| Value | When to use |
|-------|-------------|
| `ERROR` | Direct exploitation path: injection, auth bypass, credential exposure, RCE |
| `WARNING` | Misconfiguration with meaningful risk that requires context to exploit |
| `INFO` | Hygiene, style, or low-probability risk |

## `metadata` block

Required fields — all must be present:

| Field | Value |
|-------|-------|
| `kirby_id` | `KIRBY-{CAT}-{NNN}` — check `compliance-catalog.yaml` for the next ID |
| `category` | `security`, `infrastructure`, `code-quality`, `standards`, `supply-chain`, `content` |
| `subcategory` | Specific vulnerability class in kebab-case (e.g., `command-injection`) |
| `property-domain` | DPS-12 domain from the enum in `kirby-rule-schema.yaml` |
| `eedom-plugin` | Always `semgrep` for files in `semgrep/` directories |
| `compliance_mappings` | At least one entry; use framework IDs from `kirby-rule-schema.yaml` |
| `references` | At least one authoritative URL (CWE, CVE, OWASP, vendor docs) |

## Test fixtures

Every rule requires a test file at `tests/{rule-id}_test.{ext}`.

Annotate test lines with Semgrep test comments:

```python
# Positive case — MUST trigger the rule
os.system(f"ls {user_dir}")  # ruleid: command-injection

# Negative case — must NOT trigger the rule
subprocess.run(["ls", user_dir], shell=False)  # ok: command-injection
```

Run `semgrep --test rules/{category}/semgrep/{rule-id}.yaml tests/` to verify before submitting.

Test fixture requirements:
- At least 2 positive cases covering the most common variants
- At least 1 negative case representing genuinely safe code
- Negative cases must be realistic — not contrived bypasses of the pattern
