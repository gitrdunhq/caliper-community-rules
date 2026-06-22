# Bandit — Python Security Scanner

[Bandit](https://bandit.readthedocs.io/) is a static analysis tool designed to find common security issues in Python code. It processes each file, builds an AST, and runs appropriate plugins against the AST nodes to detect dangerous patterns.

## What Bandit catches

| Category | Examples |
|----------|---------|
| **Injection** | Shell injection via `subprocess(shell=True)`, SQL string concatenation, `exec()`/`eval()` |
| **Hardcoded secrets** | Passwords in source, default password arguments, hardcoded connection strings |
| **Weak cryptography** | MD5/DES usage, non-cryptographic `random` for security, insecure cipher modes |
| **Unsafe deserialization** | `pickle.load()`, `marshal.load()`, `yaml.load()` without SafeLoader |
| **Dangerous file ops** | World-writable permissions, hardcoded `/tmp` paths, `mktemp` race conditions |
| **Error handling** | Bare `try/except: pass` that silently swallows security-relevant errors |
| **Network** | Binding to `0.0.0.0`, unvalidated `urllib.urlopen()`, HTTP without TLS |
| **Template injection** | Jinja2 with `autoescape=False`, Mako templates, Django `mark_safe()` |

## How Caliper integrates Bandit

Caliper runs Bandit as a subprocess against the target repository, parses the JSON output, and maps each finding to the caliper severity model. The integration:

1. Invokes `bandit -r <target_dirs> --format json -c bandit-profile.yaml`
2. Parses structured JSON output (test ID, severity, confidence, filename, line number, code snippet)
3. Maps Bandit severity + confidence to caliper severity using the matrix below
4. Deduplicates findings and merges into the unified caliper report

### Severity mapping

| Bandit Severity | Bandit Confidence | caliper Severity |
|-----------------|-------------------|----------------|
| HIGH | HIGH | critical |
| HIGH | MEDIUM | high |
| MEDIUM | HIGH | high |
| MEDIUM | MEDIUM | warning |
| LOW | * | info |

Rationale: A HIGH-severity finding with HIGH confidence is a confirmed dangerous pattern -- critical. When confidence drops, severity drops one tier. LOW-severity Bandit findings are informational regardless of confidence since they represent style issues or minor concerns.

## Key checks

### Injection & execution (B101-B108)

| Check | Name | What it catches |
|-------|------|-----------------|
| B101 | `assert_used` | `assert` statements that get optimized away with `-O` flag |
| B102 | `exec_used` | Direct `exec()` calls -- arbitrary code execution |
| B103 | `set_bad_file_permissions` | `os.chmod()` with overly permissive modes (e.g., `0o777`) |
| B104 | `hardcoded_bind_all_interfaces` | Binding to `0.0.0.0` -- exposes service to all network interfaces |
| B105 | `hardcoded_password_string` | Passwords assigned as string literals |
| B106 | `hardcoded_password_funcarg` | Passwords passed as default function arguments |
| B107 | `hardcoded_password_default` | Default parameter values that look like passwords |
| B108 | `hardcoded_tmp_directory` | Hardcoded `/tmp` paths vulnerable to symlink attacks |

### Error handling (B110)

| Check | Name | What it catches |
|-------|------|-----------------|
| B110 | `try_except_pass` | `except: pass` blocks that silently swallow all errors |

### Cryptography & deserialization (B301-B506)

| Check | Name | What it catches |
|-------|------|-----------------|
| B301 | `pickle` | `pickle.loads()` -- arbitrary code execution via crafted payloads |
| B302 | `marshal` | `marshal.loads()` -- same risk as pickle |
| B303 | `md5` | MD5 usage -- broken hash, collision attacks trivial |
| B304 | `des` | DES/3DES encryption -- broken cipher |
| B305 | `cipher` | Insecure cipher modes (ECB, etc.) |
| B306 | `mktemp_q` | `tempfile.mktemp()` -- race condition, use `mkstemp()` instead |
| B307 | `eval` | `eval()` -- arbitrary code execution, same risk class as `exec()` |
| B310 | `urllib_urlopen` | `urllib.urlopen()` with unvalidated URLs |
| B311 | `random` | `random` module for security-sensitive operations (use `secrets`) |
| B506 | `yaml_load` | `yaml.load()` without SafeLoader -- arbitrary code execution |

### Shell injection (B601-B608)

| Check | Name | What it catches |
|-------|------|-----------------|
| B601 | `paramiko_calls` | Paramiko SSH command execution with user input |
| B602 | `subprocess_popen_with_shell_equals_true` | `subprocess.Popen(cmd, shell=True)` -- shell injection |
| B603 | `subprocess_without_shell_equals_true` | `subprocess.Popen(cmd)` without `shell=True` but with untrusted input |
| B604 | `any_other_function_with_shell_equals_true` | Any function call with `shell=True` |
| B605 | `start_process_with_a_shell` | `os.system()`, `os.popen()` -- shell injection |
| B606 | `start_process_with_no_shell` | `os.execl()`, `os.spawnl()` with untrusted input |
| B607 | `start_process_with_partial_path` | Subprocess calls without absolute path -- PATH injection |
| B608 | `hardcoded_sql_expressions` | SQL strings built via concatenation or f-strings |

### Template injection (B701-B703)

| Check | Name | What it catches |
|-------|------|-----------------|
| B701 | `jinja2_autoescape_false` | Jinja2 templates with autoescaping disabled -- XSS |
| B702 | `use_of_mako_templates` | Mako templates -- no autoescaping by default |
| B703 | `django_mark_safe` | `mark_safe()` on user-controlled content -- XSS |

## Files in this directory

| File | Purpose |
|------|---------|
| `bandit.config.yaml` | caliper plugin configuration (severity mapping, target dirs, timeouts) |
| `bandit-profile.yaml` | Curated Bandit profile enabling security-critical checks |
| `test-cases.py` | Positive and negative test cases for validating check coverage |

## References

- [Bandit documentation](https://bandit.readthedocs.io/en/latest/)
- [Bandit check list](https://bandit.readthedocs.io/en/latest/plugins/index.html)
- [Bandit GitHub](https://github.com/PyCQA/bandit)
- [OWASP Python Security](https://owasp.org/www-project-python-security/)
