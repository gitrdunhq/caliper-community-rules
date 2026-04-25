"""
Bandit test cases for eedom community rules.

Each section demonstrates a Bandit check with:
  - VULNERABLE: code that should trigger the check
  - SAFE: equivalent code that should NOT trigger

Run against this file to validate Bandit integration:
  bandit -c bandit-profile.yaml test-cases.py
"""

import ast
import hashlib
import os
import secrets
import subprocess
import tempfile

# =============================================================================
# B102: exec_used -- arbitrary code execution
# =============================================================================

# VULNERABLE: exec() runs arbitrary code strings
user_input = "print('hello')"
exec(user_input)  # noqa: B102

# SAFE: ast.literal_eval only evaluates literals, not arbitrary code
user_data = "{'key': 'value'}"
parsed = ast.literal_eval(user_data)


# =============================================================================
# B103: set_bad_file_permissions -- overly permissive chmod
# =============================================================================

# VULNERABLE: world-readable and world-writable
os.chmod("config.ini", 0o777)  # noqa: B103

# SAFE: owner read/write only
os.chmod("config.ini", 0o600)


# =============================================================================
# B105: hardcoded_password_string -- passwords in source
# =============================================================================

# VULNERABLE: password as a string literal
password = "super_secret_123"  # noqa: B105

# SAFE: password from environment
password = os.environ.get("DB_PASSWORD")


# =============================================================================
# B106: hardcoded_password_funcarg -- password as function argument
# =============================================================================


# VULNERABLE: password default in function call
def connect_db(host, password="changeme"):  # noqa: B107
    pass


connect_db("localhost", password="admin123")  # noqa: B106

# SAFE: password injected from config
connect_db("localhost", password=os.environ["DB_PASSWORD"])


# =============================================================================
# B108: hardcoded_tmp_directory -- /tmp paths
# =============================================================================

# VULNERABLE: hardcoded /tmp is world-writable, symlink attacks possible
tmp_path = "/tmp/myapp_data"  # noqa: B108

# SAFE: tempfile module creates secure temporary directories
tmp_path = tempfile.mkdtemp(prefix="myapp_")


# =============================================================================
# B110: try_except_pass -- silent exception swallowing
# =============================================================================

# VULNERABLE: silently ignores ALL errors including security failures
try:
    os.remove("lockfile")
except Exception:
    pass  # noqa: B110

# SAFE: catch specific exception, log or handle meaningfully
try:
    os.remove("lockfile")
except FileNotFoundError:
    pass  # file already gone -- expected, not an error


# =============================================================================
# B303: md5 -- broken hash algorithm
# =============================================================================

# VULNERABLE: MD5 is collision-broken, unsuitable for security
digest = hashlib.md5(b"data").hexdigest()  # noqa: B303

# SAFE: SHA-256 is collision-resistant
digest = hashlib.sha256(b"data").hexdigest()


# =============================================================================
# B311: random -- non-cryptographic randomness
# =============================================================================

import random  # noqa: E402

# VULNERABLE: stdlib random uses Mersenne Twister -- predictable
token = "".join(random.choices("abcdef0123456789", k=32))  # noqa: B311

# SAFE: secrets module uses OS entropy source
token = secrets.token_hex(16)


# =============================================================================
# B602: subprocess_popen_with_shell_equals_true -- shell injection
# =============================================================================

# VULNERABLE: shell=True passes cmd through /bin/sh -- injection via user_cmd
user_cmd = "ls -la"
subprocess.call(user_cmd, shell=True)  # noqa: B602

# SAFE: list form bypasses the shell entirely
subprocess.call(["ls", "-la"])


# =============================================================================
# B605: start_process_with_a_shell -- os.system
# =============================================================================

# VULNERABLE: os.system runs through the shell -- classic injection vector
filename = "report.txt"
os.system("cat " + filename)  # noqa: B605

# SAFE: subprocess with list args, no shell
subprocess.run(["cat", filename], check=True)


# =============================================================================
# B608: hardcoded_sql_expressions -- SQL injection
# =============================================================================

# VULNERABLE: string concatenation builds SQL -- injection via user_id
user_id = "1; DROP TABLE users; --"
query = "SELECT * FROM users WHERE id = " + user_id  # noqa: B608

# SAFE: parameterized query -- database driver handles escaping
query = "SELECT * FROM users WHERE id = %s"
# cursor.execute(query, (user_id,))


# =============================================================================
# B701: jinja2_autoescape_false -- XSS via template injection
# =============================================================================

from jinja2 import Environment  # noqa: E402

# VULNERABLE: autoescape disabled -- user input rendered as raw HTML
env = Environment(autoescape=False)  # noqa: B701

# SAFE: autoescape enabled -- HTML entities escaped automatically
env = Environment(autoescape=True)
