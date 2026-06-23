---
description: 'Review focus areas for Kirby scanner rule PRs'
applyTo: '**'
excludeAgent: ["coding-agent"]
---

# Kirby Rule PR Review

Scanner rule PRs have a different failure mode than application code PRs. A bug here ships to every caliper user and either floods them with false positives or silently misses vulnerabilities. Review with that in mind.

Use the following severity tiers for all comments:

```
[CRITICAL]    Blocks merge. The rule is wrong, missing tests, or has a compliance mapping error.
[IMPORTANT]   Should fix before merge. The rule works but has a quality issue.
[SUGGESTION]  Take it or leave it. Additional coverage, improved wording, edge cases.
```

Comment format:

```
**[PRIORITY] Category: Brief title**

Description of the issue.

**Why this matters:**
Impact if shipped.

**Suggested fix:**
Direction or code example.
```

---

## CRITICAL — Merge blockers

### Compliance mapping accuracy

Every control ID in `compliance_mappings` must be verified against `compliance-catalog.yaml` and `kirby-rule-schema.yaml`. Check:

- Framework ID is a valid enum value (e.g., `owasp-top10-2021`, not `OWASP-2021` or `owasp-top10`)
- Control IDs exist in the framework (e.g., `A03:2021` not `A3` or `Injection`)
- The control actually covers what the rule detects — do not map an injection rule to an access control control

**Example violation:**
```yaml
# WRONG — CIS control ID format incorrect
- framework: cis-aws-v2.0
  controls: ["2.1"]  # should be "2.1.1" or similar — verify against the catalog
```

### Pattern correctness

Does the Semgrep/tfsec/cfn-nag pattern actually match the vulnerability described in the rule's `message` or `description`? Verify by reading the pattern alongside the `message`. Common failures:

- The pattern is too narrow — only catches a specific variable name instead of the vulnerability class
- The pattern uses hardcoded string matching where a metavariable should be used
- A tfsec `matchSpec` predicate has inverted logic (checking `isFalse` when the violation is presence, not absence)
- A `pattern-not` silences the rule for legitimate attack variants

### False negative risk

The rule must catch the common variants of the described vulnerability. Check:

- Are equivalent APIs covered? (e.g., `os.system` + `os.popen` + `subprocess` variants for command injection)
- Are common string construction methods covered? (f-strings, concatenation, `.format()`)
- Is the negative case realistic — does it actually represent safe code, or is it a contrived bypass?

Flag any obvious variant that the current patterns miss.

### Test fixture coverage

The PR must include test fixtures with both positive and negative cases.

- Positive cases: annotated with `# ruleid: {rule-id}` (Semgrep) or placed in a FAIL block (tfsec)
- Negative cases: annotated with `# ok: {rule-id}` (Semgrep) or placed in a PASS block (tfsec)
- Test file must be in the correct `tests/` directory alongside the rule

A rule with no tests ships blind. Block it.

---

## IMPORTANT — Fix before merge

### Property domain accuracy

The `property_domain` field must match what the rule actually enforces. Common mismatches:

- Injection rules → `integrity` (attacker changes behavior), not `confidentiality`
- Credential exposure rules → `confidentiality`, not `integrity`
- Missing backup/redundancy rules → `availability`
- Non-deterministic build rules → `determinism`

If the mapping is off, downstream compliance reports will misclassify the finding.

### Severity calibration

`severity: ERROR` is reserved for vulnerabilities that have direct, high-probability exploitation paths (injection, auth bypass, credential exposure). `WARNING` covers misconfigurations with meaningful risk. `INFO` is for style/hygiene issues.

Common calibration errors:
- Missing TLS configuration flagged as ERROR when INFO or WARNING is more appropriate given deployment context
- Secret scanning rules set to INFO when a leaked credential should be ERROR

### Message quality

The `message` field (Semgrep) or `errorMessage` / `description` + `resolution` fields (tfsec) must answer three questions:

1. What was detected?
2. Why is it dangerous?
3. What is the correct fix?

Messages that only state what was detected ("Found os.system call") without explaining the risk or fix are not sufficient. Developers see this message in their PR — it needs to be actionable.

### Metavariable regex quality

`metavariable-regex` patterns should match the intended values and not over-capture. Check:

- Anchors (`^...$`) are present where appropriate to prevent substring matches
- The regex handles common variants of the target value
- The regex is not so broad that it matches unrelated identifiers

### tfsec matchSpec predicate logic

For tfsec JSON rules, verify the `matchSpec` logic matches the stated intent:

- `isTrue` / `isFalse` — boolean attribute checks
- `equals` / `notEquals` — value equality
- `isPresent` / `isAbsent` — attribute existence
- `and` / `or` — compound logic with `predicateMatchSpec` array

Compound `and`/`or` specs are commonly inverted. Trace the predicate tree manually against the PASS and FAIL fixture blocks to confirm the logic is correct.

---

## SUGGESTION — Optional improvements

### Additional compliance mappings

If the rule covers a control that maps to additional frameworks not listed, suggest adding them. For example, a rule already mapped to `owasp-top10-2021` and `nist-800-53-r5` might also apply to:

- `pci-dss-v4.0` if the vulnerability class is in PCI scope
- `hipaa-security` if the rule covers PHI handling
- `soc2-tsc` if the rule covers availability or confidentiality controls

Check `compliance-catalog.yaml` for how similar rules are mapped.

### Alternative or additional patterns

If you know of a common variant of the vulnerability that the current patterns miss, suggest adding it. Phrase it as a suggestion, not a blocker, unless the missing variant represents a significant false-negative risk (in which case escalate to CRITICAL).

### Test fixture diversity

More edge cases in fixtures improve confidence. Suggest additional positive cases if there are known evasion patterns, or additional negative cases if the rule's safe-code boundary is unclear.
