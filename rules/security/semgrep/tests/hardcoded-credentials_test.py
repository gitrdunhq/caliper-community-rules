"""
Semgrep test file for hardcoded-credentials (KIRBY-SEC-005).

Positive cases are annotated with:  todoruleid: hardcoded-credentials
Negative cases are annotated with:  ok: hardcoded-credentials

Run with:
  semgrep --test rules/security/semgrep/hardcoded-credentials.yaml \
          rules/security/semgrep/tests/hardcoded-credentials_test.py
"""

import getpass
import os

# ==================== POSITIVE CASES ====================
# These must each trigger the rule exactly once.

# Pattern 1 — password variable with non-trivial value
# todoruleid: hardcoded-credentials
password = "hunter2IsMyPass!"

# Pattern 1 — api_key variable with non-trivial value
# todoruleid: hardcoded-credentials
api_key = "sk-prod-1234567890abcdef"

# Pattern 1 — secret variable with random-looking value
# todoruleid: hardcoded-credentials
secret = "Xk9mNP2rQvL8wZj3"

# Pattern 1 — access_token with JWT-like value
# todoruleid: hardcoded-credentials
access_token = "eyJhbGciOiJIUzI1NiJ9.valid.sig"

# Pattern 1 — api_secret with a production-looking value
# todoruleid: hardcoded-credentials
api_secret = "live_prod_key_7f3a9b2c1d4e5f6a"

# Pattern 2 — AWS access key ID (AKIA + 16 uppercase alphanumeric chars)
# todoruleid: hardcoded-credentials
AWS_ACCESS_KEY_ID = "AKIAIOSFODNN7EXAMPLE"

# Pattern 3 — PostgreSQL connection string with a non-placeholder password
# todoruleid: hardcoded-credentials
database_url = "postgresql://admin:Sup3rS3cr3t@prod.db.example.com/mydb"

# Pattern 3 — MySQL connection string with embedded credential
# todoruleid: hardcoded-credentials
mysql_url = "mysql://root:Pr0dR00tPass@db.internal/app"

# Pattern 4 — os.environ.get with a long hardcoded fallback for a password key
# todoruleid: hardcoded-credentials
db_password = os.environ.get("DB_PASSWORD", "d3f@ultS3cr3tV4lu3!")

# Pattern 4 — os.environ.get with a long hardcoded fallback for a token key
# todoruleid: hardcoded-credentials
stripe_key = os.environ.get("STRIPE_SECRET_KEY", "notreal_tk_abcdef1234567890ghijklmnop")

# Pattern 5 — config dict with "password" key and a non-trivial value
# todoruleid: hardcoded-credentials
db_config = {"password": "Pr0ductionP@ssw0rd!"}

# Pattern 5 — credentials dict with "api_key" key
# todoruleid: hardcoded-credentials
auth_payload = {"api_key": "live_key_7f3a9b2c1d4e5f6a", "env": "production"}


# ==================== NEGATIVE CASES ====================
# These must NOT trigger the rule.

# Reading from environment variable — no string literal on RHS
# ok: hardcoded-credentials
password = os.environ["PASSWORD"]

# Empty string — too short (length 0 < 8)
# ok: hardcoded-credentials
password = ""

# Common placeholder word — excluded by value filter
# ok: hardcoded-credentials
password = "changeme"

# Very short value — too short (length 3 < 8)
# ok: hardcoded-credentials
secret = "xxx"

# Placeholder with "your_" prefix — excluded by value filter
# ok: hardcoded-credentials
api_key = "your_api_key_here"

# Reading from environment without a fallback — RHS is not a string literal
# ok: hardcoded-credentials
db_password = os.environ.get("DB_PASSWORD")

# User-prompted input — RHS is a function call, not a string literal
# ok: hardcoded-credentials
password = getpass.getpass()

# Connection string where the password segment is the placeholder word "password"
# ok: hardcoded-credentials
test_db_url = "postgresql://user:password@localhost/testdb"

# Connection string where the password segment is "changeme"
# ok: hardcoded-credentials
dev_db_url = "mysql://dev:changeme@localhost/devdb"

# os.environ.get with an empty string fallback — length 0 fails the 16-char minimum
# ok: hardcoded-credentials
api_key = os.environ.get("STRIPE_KEY", "")

# os.environ.get with a short fallback — "debug" is 5 chars, below 16-char minimum
# ok: hardcoded-credentials
debug_flag = os.environ.get("DB_PASSWORD", "debug")

# os.environ.get where the key name has no credential term — key filter blocks it
# ok: hardcoded-credentials
retry_limit = os.environ.get("RETRY_COUNT", "DefaultRetryValueNotACredential")

# Non-credential variable with a long string value — variable name filter blocks it
# ok: hardcoded-credentials
description = "This is a long descriptive text string that is definitely not a credential"

# Dict with a credential key but a placeholder value — value filter blocks it
# ok: hardcoded-credentials
test_config = {"password": "example"}
