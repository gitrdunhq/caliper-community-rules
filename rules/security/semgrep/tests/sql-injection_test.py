"""
Semgrep test file for sql-injection (KIRBY-SEC-008).

Positive cases are annotated with:  # ruleid: sql-injection
Negative cases are annotated with:  # ok: sql-injection

Run with:
  semgrep --test rules/security/semgrep/sql-injection.yaml \
          rules/security/semgrep/tests/sql-injection_test.py
"""

import sqlite3

from sqlalchemy import create_engine, text

conn = sqlite3.connect(":memory:")
cursor = conn.cursor()
engine = create_engine("sqlite:///:memory:")
connection = engine.connect()

# Stub values — obviously fake, no real credentials or secrets.
username = "test_user"
customer_name = "test_customer"
category = "test_category"
owner_id = "test_owner"
session_token = "test_token"  # noqa: S105
table_name = "test_table"
record_id = "test_record"
search_term = "test_search"
new_role = "test_role"
user_id = "test_user_id"
new_balance = "test_balance"
account_id = "test_account"
action = "test_action"


# ==================== POSITIVE CASES ====================
# These must each trigger the rule exactly once.

# Pattern 1 — f-string interpolated directly into cursor.execute
# ruleid: sql-injection
cursor.execute(f"SELECT * FROM users WHERE name = '{username}'")

# Pattern 2 — string concatenation in cursor.execute
# ruleid: sql-injection
cursor.execute("SELECT * FROM orders WHERE customer = '" + customer_name + "'")

# Pattern 3 — Python % formatting used to build the query string
# ruleid: sql-injection
cursor.execute("SELECT * FROM products WHERE category = '%s'" % category)

# Pattern 4 — SQLAlchemy engine.execute with f-string (deprecated but still in use)
# ruleid: sql-injection
engine.execute(f"SELECT * FROM accounts WHERE owner = '{owner_id}'")

# Pattern 5 — SQLAlchemy text() wrapper with f-string
# ruleid: sql-injection
connection.execute(text(f"SELECT * FROM sessions WHERE token = '{session_token}'"))

# Pattern 6 — f-string with table name interpolation (still dangerous)
# ruleid: sql-injection
cursor.execute(f"DELETE FROM {table_name} WHERE id = {record_id}")

# Pattern 7 — concatenation with variable on the left side
# ruleid: sql-injection
cursor.execute(search_term + " FROM admin_users")

# Pattern 8 — Python % formatting with a tuple (string format op, not SQL bind)
# ruleid: sql-injection
cursor.execute("UPDATE users SET role = '%s' WHERE id = '%s'" % (new_role, user_id))


# ==================== NEGATIVE CASES ====================
# These must NOT trigger the rule.

# Safe — parameterized query using %s placeholder with a tuple (DB driver handles binding)
# ok: sql-injection
cursor.execute("SELECT * FROM users WHERE name = %s", (username,))

# Safe — parameterized query using ? placeholder (sqlite3 style)
# ok: sql-injection
cursor.execute("SELECT * FROM orders WHERE customer = ?", (customer_name,))

# Safe — hardcoded query with no user input at all
# ok: sql-injection
cursor.execute("SELECT COUNT(*) FROM users WHERE active = 1")

# Safe — parameterized query with multiple placeholders and a tuple
# ok: sql-injection
cursor.execute("UPDATE accounts SET balance = %s WHERE id = %s", (new_balance, account_id))

# Safe — SQLAlchemy text() with named bound parameters (no f-string)
# ok: sql-injection
connection.execute(text("SELECT * FROM users WHERE id = :user_id"), {"user_id": user_id})

# Safe — parameterized query with tuple as second arg (not Python % string formatting)
# ok: sql-injection
cursor.execute("INSERT INTO logs (action, user) VALUES (%s, %s)", (action, user_id))

# Safe — hardcoded DELETE with no user-controlled values
# ok: sql-injection
cursor.execute("DELETE FROM expired_sessions WHERE created_at < '2024-01-01'")
