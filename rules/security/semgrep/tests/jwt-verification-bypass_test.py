"""
Semgrep test file for jwt-verification-bypass (KIRBY-SEC-011).

Positive cases are annotated with:  ruleid: jwt-verification-bypass
Negative cases are annotated with:  ok: jwt-verification-bypass

Run with:
  semgrep --test rules/security/semgrep/jwt-verification-bypass.yaml \
          rules/security/semgrep/tests/jwt-verification-bypass_test.py
"""

import jwt
import jose.jwt

# ---------------------------------------------------------------------------
# Test fixtures — obviously fake values, not real credentials.
# Semgrep tests are structural; these variables just satisfy the linter.
# ---------------------------------------------------------------------------
token = "test.jwt.token"
signing_key = "test-hmac-signing-key-for-unit-tests-only"
public_key = "-----BEGIN PUBLIC KEY-----\nTESTKEY\n-----END PUBLIC KEY-----"

# ==================== POSITIVE CASES ====================

# Pattern 1 — PyJWT: verify_signature disabled in options
# ruleid: jwt-verification-bypass
payload = jwt.decode(token, options={"verify_signature": False})

# Pattern 1 — PyJWT: verify_signature disabled with other options present
# ruleid: jwt-verification-bypass
payload = jwt.decode(
    token, "fake-signing-key", options={"verify_exp": True, "verify_signature": False}
)

# Pattern 2 — PyJWT: "none" algorithm accepted (unsigned tokens)
# ruleid: jwt-verification-bypass
payload = jwt.decode(token, algorithms=["none"])

# Pattern 3 — PyJWT older API: verify=False keyword flag
# ruleid: jwt-verification-bypass
payload = jwt.decode(token, "fake-signing-key", verify=False)

# Pattern 4 — python-jose: audience verification disabled
# ruleid: jwt-verification-bypass
payload = jose.jwt.decode(
    token, "fake-jose-key", algorithms=["HS256"], options={"verify_aud": False}
)

# Pattern 4 — python-jose: expiry verification disabled
# ruleid: jwt-verification-bypass
payload = jose.jwt.decode(
    token, "fake-jose-key", algorithms=["HS256"], options={"verify_exp": False}
)

# Pattern 4 — python-jose: both audience and expiry disabled
# ruleid: jwt-verification-bypass
payload = jose.jwt.decode(
    token,
    "fake-jose-key",
    algorithms=["HS256"],
    options={"verify_aud": False, "verify_exp": False},
)


# ==================== NEGATIVE CASES ====================

# Safe: proper PyJWT decode with secret and HS256 algorithm
# ok: jwt-verification-bypass
payload = jwt.decode(token, signing_key, algorithms=["HS256"])

# Safe: proper PyJWT decode with RS256 public key
# ok: jwt-verification-bypass
payload = jwt.decode(token, public_key, algorithms=["RS256"])

# Safe: PyJWT options dict with all verifications enabled
# ok: jwt-verification-bypass
payload = jwt.decode(
    token,
    signing_key,
    algorithms=["HS256"],
    options={"verify_exp": True, "verify_aud": True},
)

# Safe: python-jose full verification (no disabled claims)
# ok: jwt-verification-bypass
payload = jose.jwt.decode(token, public_key, algorithms=["RS256"])

# Safe: jwt.encode — not a decode call, not vulnerable to verification bypass
# ok: jwt-verification-bypass
token = jwt.encode({"sub": "user-id-42"}, signing_key, algorithm="HS256")

# Safe: algorithms list with a real algorithm — not "none"
# ok: jwt-verification-bypass
payload = jwt.decode(token, signing_key, algorithms=["HS512"])

# Safe: python-jose with only leeway option (not a verification bypass)
# ok: jwt-verification-bypass
payload = jose.jwt.decode(token, public_key, algorithms=["RS256"], options={"leeway": 10})
