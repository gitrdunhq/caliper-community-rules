# Test fixtures for KIRBY-SEC-007 — Insecure TLS Configuration (Semgrep)
# Semgrep test annotations:
#   # ruleid: insecure-tls-config  — this line should be flagged
#   # ok: insecure-tls-config      — this line should NOT be flagged

import ssl
import requests
import urllib3

# --------------------------------------------------------------------------
# POSITIVE cases — must be flagged by insecure-tls-config
# --------------------------------------------------------------------------

# ruleid: insecure-tls-config
ctx = ssl.SSLContext(ssl.PROTOCOL_TLSv1)

# ruleid: insecure-tls-config
ctx2 = ssl.SSLContext(ssl.PROTOCOL_TLSv1_1)

# ruleid: insecure-tls-config
ctx.minimum_version = ssl.TLSVersion.TLSv1

# ruleid: insecure-tls-config
ctx.minimum_version = ssl.TLSVersion.TLSv1_1

# ruleid: insecure-tls-config
response = requests.get("https://internal.example.com", verify=False)

# ruleid: insecure-tls-config
response = requests.post("https://api.example.com/data", json={}, verify=False)

# ruleid: insecure-tls-config
ctx.check_hostname = False

# ruleid: insecure-tls-config
ctx.verify_mode = ssl.CERT_NONE

# ruleid: insecure-tls-config
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# --------------------------------------------------------------------------
# NEGATIVE cases — must NOT be flagged by insecure-tls-config
# --------------------------------------------------------------------------

# ok: insecure-tls-config
ctx_secure = ssl.SSLContext(ssl.PROTOCOL_TLS_CLIENT)

# ok: insecure-tls-config
ctx_secure.minimum_version = ssl.TLSVersion.TLSv1_2

# ok: insecure-tls-config
ctx_secure.minimum_version = ssl.TLSVersion.TLSv1_3

# ok: insecure-tls-config
response = requests.get("https://example.com", verify=True)

# ok: insecure-tls-config
response = requests.get("https://example.com")

# ok: insecure-tls-config
response = requests.get("https://example.com", verify="/path/to/ca-bundle.crt")

# ok: insecure-tls-config
response = requests.post("https://example.com", json={})

# ok: insecure-tls-config
ctx_secure.check_hostname = True

# ok: insecure-tls-config
ctx_secure.verify_mode = ssl.CERT_REQUIRED
