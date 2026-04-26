"""
Semgrep test file for weak-crypto-algorithms (KIRBY-SEC-016).

Positive cases are annotated with:  # ruleid: weak-crypto-algorithms
Negative cases are annotated with:  # ok: weak-crypto-algorithms

Run with:
  semgrep --test rules/security/semgrep/weak-crypto-algorithms.yaml \
          rules/security/semgrep/tests/weak-crypto-algorithms_test.py
"""

import hashlib
import hmac

# Stub data — not real secrets, only used to satisfy name resolution.
data = b"example data for hashing"
key = b"example-hmac-key-stub"
message = b"example message payload"

# ==================== POSITIVE CASES ====================
# These must each trigger the rule exactly once.

# Pattern 1 — hashlib.md5() direct constructor (broken, collision-prone)
# ruleid: weak-crypto-algorithms
digest = hashlib.md5(data)

# Pattern 2 — hashlib.sha1() direct constructor (deprecated, SHAttered attack)
# ruleid: weak-crypto-algorithms
digest = hashlib.sha1(data)

# Pattern 3a — hashlib.new() with "md5" string (dynamic construction, still MD5)
# ruleid: weak-crypto-algorithms
digest = hashlib.new("md5", data)

# Pattern 3b — hashlib.new() with "sha1" string
# ruleid: weak-crypto-algorithms
digest = hashlib.new("sha1", data)

# Pattern 4 — hashlib.md5() with no initial data (incremental update pattern)
# ruleid: weak-crypto-algorithms
h = hashlib.md5()

# Pattern 5 — hashlib.sha1() with no initial data
# ruleid: weak-crypto-algorithms
h = hashlib.sha1()

# Pattern 6 — hmac.new() with MD5 as positional string digestmod
# ruleid: weak-crypto-algorithms
mac = hmac.new(key, message, "md5")

# Pattern 7 — hmac.new() with hashlib.md5 as positional callable digestmod
# ruleid: weak-crypto-algorithms
mac = hmac.new(key, message, hashlib.md5)

# Pattern 8 — hmac.new() with hashlib.sha1 as positional callable digestmod
# ruleid: weak-crypto-algorithms
mac = hmac.new(key, message, hashlib.sha1)


# ==================== NEGATIVE CASES ====================
# These must NOT trigger the rule.

# Negative 1 — SHA-256 is safe and recommended
# ok: weak-crypto-algorithms
digest = hashlib.sha256(data)

# Negative 2 — SHA-384 is safe and recommended
# ok: weak-crypto-algorithms
digest = hashlib.sha384(data)

# Negative 3 — SHA-512 is safe and recommended
# ok: weak-crypto-algorithms
digest = hashlib.sha512(data)

# Negative 4 — BLAKE2b is modern and safe
# ok: weak-crypto-algorithms
digest = hashlib.blake2b(data)

# Negative 5 — BLAKE2s is modern and safe
# ok: weak-crypto-algorithms
digest = hashlib.blake2s(data)

# Negative 6 — hashlib.new() with sha256 is safe
# ok: weak-crypto-algorithms
digest = hashlib.new("sha256", data)

# Negative 7 — hashlib.new() with sha512 is safe
# ok: weak-crypto-algorithms
digest = hashlib.new("sha512", data)

# Negative 8 — hmac.new() with SHA-256 callable is safe
# ok: weak-crypto-algorithms
mac = hmac.new(key, message, hashlib.sha256)

# Negative 9 — hmac.new() with SHA-512 callable is safe
# ok: weak-crypto-algorithms
mac = hmac.new(key, message, hashlib.sha512)

# Negative 10 — hmac.new() with "sha256" string digestmod is safe
# ok: weak-crypto-algorithms
mac = hmac.new(key, message, "sha256")
