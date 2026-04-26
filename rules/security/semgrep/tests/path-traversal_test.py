"""
Semgrep test file for path-traversal (KIRBY-SEC-014).

Positive cases are annotated with:  todoruleid: path-traversal
Negative cases are annotated with:  ok: path-traversal

Run with:
  semgrep --test rules/security/semgrep/path-traversal.yaml \
          rules/security/semgrep/tests/path-traversal_test.py
"""

import os
import pathlib
import shutil
from pathlib import Path

# ---------------------------------------------------------------------------
# Test fixtures — obviously fake values used to satisfy the linter.
# ---------------------------------------------------------------------------
user_filename = "report.txt"
base_dir = "/var/app/files"
user_path = "user-supplied-subpath"
user_src = "user-uploaded-file.zip"
dest_dir = "/var/app/output"
output_dir = "/var/app/output"

# ==================== POSITIVE CASES ====================

# Pattern 1 — open() with string concatenation as path
# todoruleid: path-traversal
f = open(base_dir + user_filename, "r")

# Pattern 1 — open() with concatenated path using separator
# todoruleid: path-traversal
f = open(base_dir + "/" + user_filename, "rb")

# Pattern 2 — open() with os.path.join result (join can be escaped with absolute path)
# todoruleid: path-traversal
f = open(os.path.join(base_dir, user_path), "r")

# Pattern 2 — open() with nested os.path.join
# todoruleid: path-traversal
f = open(os.path.join(base_dir, "subdir", user_filename), "r")

# Pattern 3 — pathlib.Path() constructed from a non-literal value
# todoruleid: path-traversal
p = pathlib.Path(user_path)

# Pattern 3 — imported Path() constructed from a non-literal value
# todoruleid: path-traversal
p = Path(user_filename)

# Pattern 4 — shutil.copy with a non-literal source path
# todoruleid: path-traversal
shutil.copy(user_src, dest_dir)

# Pattern 4 — shutil.copyfile with a non-literal source path
# todoruleid: path-traversal
shutil.copyfile(user_src, os.path.join(output_dir, "archived.zip"))


# ==================== NEGATIVE CASES ====================

# Safe: open() with a fully hardcoded path
# ok: path-traversal
f = open("config/settings.json", "r")

# Safe: open() with another hardcoded path
# ok: path-traversal
f = open("/etc/app/defaults.cfg", "r")

# Safe: os.path.join with only hardcoded components
# ok: path-traversal
p = os.path.join("/var/app/static", "index.html")

# Safe: pathlib.Path() with a hardcoded literal
# ok: path-traversal
p = pathlib.Path("/var/log/app.log")

# Safe: imported Path() with a hardcoded literal
# ok: path-traversal
p = Path("uploads/avatars")

# Safe: shutil.copy with a hardcoded source
# ok: path-traversal
shutil.copy("templates/base.html", output_dir)

# Safe: shutil.copyfile with a hardcoded source
# ok: path-traversal
shutil.copyfile("static/favicon.ico", os.path.join(output_dir, "favicon.ico"))
