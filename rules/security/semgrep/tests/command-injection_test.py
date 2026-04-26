"""
Semgrep test file for command-injection (KIRBY-SEC-009).

Positive cases are annotated with:  # ruleid: command-injection
Negative cases are annotated with:  # ok: command-injection

Run with:
  semgrep --test rules/security/semgrep/command-injection.yaml \
          rules/security/semgrep/tests/command-injection_test.py
"""

import os
import subprocess

# Stub values — obviously fake, no real credentials or secrets.
filename = "test_file.txt"
user_input = "test_input"
host = "test_host"
port = "test_port"
target_dir = "test_dir"
archive_name = "test_archive"
script_path = "test_script.sh"
search_pattern = "test_pattern"


# ==================== POSITIVE CASES ====================
# These must each trigger the rule exactly once.

# Pattern 1 — os.system with f-string (shell always used)
# ruleid: command-injection
os.system(f"cat {filename}")

# Pattern 2 — os.system with string concatenation
# ruleid: command-injection
os.system("ping -c 1 " + host)

# Pattern 3 — os.popen with f-string (shell always used)
# ruleid: command-injection
os.popen(f"grep {search_pattern} /var/log/app.log")

# Pattern 4 — subprocess.call with shell=True and f-string
# ruleid: command-injection
subprocess.call(f"tar -czf {archive_name} {target_dir}", shell=True)

# Pattern 5 — subprocess.run with shell=True and f-string
# ruleid: command-injection
subprocess.run(f"ssh {user_input}@{host} -p {port}", shell=True)

# Pattern 6 — subprocess.Popen with shell=True and f-string
# ruleid: command-injection
subprocess.Popen(f"bash {script_path}", shell=True)

# Pattern 7 — subprocess.run with shell=True and concatenation
# ruleid: command-injection
subprocess.run("rm -rf " + target_dir, shell=True)

# Pattern 8 — subprocess.call with shell=True and concatenation
# ruleid: command-injection
subprocess.call("echo " + user_input, shell=True)


# ==================== NEGATIVE CASES ====================
# These must NOT trigger the rule.

# Safe — subprocess.run with list argument (no shell expansion, user arg is isolated)
# ok: command-injection
subprocess.run(["cat", filename])

# Safe — subprocess.call with list argument
# ok: command-injection
subprocess.call(["ping", "-c", "1", host])

# Safe — subprocess.Popen with list argument and explicit shell=False
# ok: command-injection
subprocess.Popen(["bash", script_path], shell=False)

# Safe — os.system with a fully hardcoded string (no user input)
# ok: command-injection
os.system("ls -la /tmp")

# Safe — subprocess.run with hardcoded string and shell=True (no interpolation)
# ok: command-injection
subprocess.run("date", shell=True)

# Safe — subprocess.run with list and shell=False (explicit)
# ok: command-injection
subprocess.run(["grep", search_pattern, "/var/log/app.log"], shell=False)

# Safe — subprocess.run with list containing user input (list form, no shell)
# ok: command-injection
subprocess.run(["ssh", f"{user_input}@{host}", "-p", port])
