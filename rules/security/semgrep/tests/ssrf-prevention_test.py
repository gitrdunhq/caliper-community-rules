"""
Semgrep test file for ssrf-prevention (KIRBY-SEC-013).

Positive cases are annotated with:  # ruleid: ssrf-prevention
Negative cases are annotated with:  # ok: ssrf-prevention

Run with:
  semgrep --test rules/security/semgrep/ssrf-prevention.yaml \
          rules/security/semgrep/tests/ssrf-prevention_test.py
"""

import urllib.request

import httpx
import requests

# ---------------------------------------------------------------------------
# Test fixtures — obviously fake values, not real endpoints or credentials.
# ---------------------------------------------------------------------------
user_url = "http://user-supplied-url.example"
target_url = "http://another-user-supplied-url.example"
endpoint = "http://user-controlled-endpoint.example/api"
payload = {"key": "value"}
headers = {"Accept": "application/json"}

# ==================== POSITIVE CASES ====================

# Pattern 1 — requests.get with a variable URL (potential user-controlled input)
# ruleid: ssrf-prevention
resp = requests.get(user_url)

# Pattern 1 — requests.get with extra keyword args but variable URL
# ruleid: ssrf-prevention
resp = requests.get(user_url, headers=headers, timeout=30)

# Pattern 2 — requests.post with a variable URL
# ruleid: ssrf-prevention
resp = requests.post(user_url, json=payload)

# Pattern 2 — requests.put with a variable URL
# ruleid: ssrf-prevention
resp = requests.put(target_url, json=payload)

# Pattern 3 — urllib.request.urlopen with a variable URL
# ruleid: ssrf-prevention
response = urllib.request.urlopen(user_url)

# Pattern 3 — urllib.request.urlopen with extra args and variable URL
# ruleid: ssrf-prevention
response = urllib.request.urlopen(user_url, timeout=10)

# Pattern 4 — httpx.get with a variable URL
# ruleid: ssrf-prevention
resp = httpx.get(user_url)

# Pattern 5 — httpx.post with a variable URL
# ruleid: ssrf-prevention
resp = httpx.post(endpoint, json=payload)


# ==================== NEGATIVE CASES ====================

# Safe: requests.get with a fully hardcoded URL
# ok: ssrf-prevention
resp = requests.get("https://api.internal.example.com/v1/status")

# Safe: requests.post with a hardcoded service URL
# ok: ssrf-prevention
resp = requests.post("https://notifications.internal.example.com/send", json=payload)

# Safe: requests.put with a hardcoded URL
# ok: ssrf-prevention
resp = requests.put("https://storage.internal.example.com/objects", json=payload)

# Safe: urllib.request.urlopen with a hardcoded URL
# ok: ssrf-prevention
response = urllib.request.urlopen("https://crl.example.com/root.crl")

# Safe: httpx.get with a hardcoded URL
# ok: ssrf-prevention
resp = httpx.get("https://third-party-api.example.com/health")

# Safe: httpx.post with a hardcoded URL
# ok: ssrf-prevention
resp = httpx.post("https://webhook-receiver.example.com/events", json=payload)

# Safe: requests.get with a hardcoded URL and extra kwargs
# ok: ssrf-prevention
resp = requests.get("https://api.internal.example.com/data", timeout=5, headers=headers)
