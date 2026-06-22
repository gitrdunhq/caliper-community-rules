# Contributing to Caliper Community Rules

PRs are welcome. Whether you have a Semgrep rule that caught a real bug, an OPA policy that saved a deployment, or a gitleaks pattern that found a leaked token -- share it here.

## What makes a good contribution

Every rule or config must include:

1. **A test case** -- at least one positive match (code that should trigger the rule) and one negative match (code that should not trigger it).
2. **A description** -- explain what the rule catches and why it matters.
3. **Plugin category** -- which caliper plugin does this rule belong to? Put it in the matching directory.
4. **Severity rating** -- how bad is it if this pattern ships? Use one of: `ERROR`, `WARNING`, `INFO`.

## Rule format by plugin

### Semgrep rules (`semgrep/`)

Standard Semgrep YAML format. Include test files alongside the rule:

```
semgrep/
  my-rule.yaml          # the rule
  my-rule.py            # test file (positive + negative cases)
```

Test files use Semgrep's standard comment annotations:

```python
# ruleid: my-rule
bad_code_here()

# ok: my-rule
good_code_here()
```

### OPA policies (`opa/`)

Rego files with `_test.rego` companion files.

### Blast Radius scripts (`blast-radius/`)

Python or SQL scripts with a README explaining the check and example output.

### Config-based plugins

For plugins that use configuration files (kube-linter, complexity, ls-lint, cpd, trivy, osv, scancode, cspell, gitleaks, clamav, supply-chain, coding-standards), include:

- The config file
- A README explaining what it enforces
- Example output showing what a violation looks like

## PR process

1. Fork the repo
2. Create a branch: `git checkout -b my-rule`
3. Add your rule + test case in the correct plugin directory
4. Test locally with caliper: `caliper scan --rules-dir ./your-plugin-dir ./test-code`
5. Open a PR -- the template will guide you through the checklist

## Code of conduct

Be respectful. Focus on the technical merit of rules. Security findings are especially welcome.
