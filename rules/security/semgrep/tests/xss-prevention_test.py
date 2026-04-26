"""
Semgrep test file for xss-prevention (KIRBY-SEC-012).

Positive cases are annotated with:  # ruleid: xss-prevention
Negative cases are annotated with:  # ok: xss-prevention

Run with:
  semgrep --test rules/security/semgrep/xss-prevention.yaml \
          rules/security/semgrep/tests/xss-prevention_test.py
"""

import jinja2
from flask import Markup, Response, render_template
from django.utils.safestring import mark_safe

# ---------------------------------------------------------------------------
# Test fixtures — obviously fake values used to satisfy the linter.
# ---------------------------------------------------------------------------
user_input = "test-user-supplied-content"
user_name = "test-username"
template_str = "<p>Hello {{ name }}</p>"
data = {"items": [1, 2, 3]}

# ==================== POSITIVE CASES ====================

# Pattern 1 — Flask Markup wrapping a variable (bypasses auto-escaping)
# ruleid: xss-prevention
safe_html = Markup(user_input)

# Pattern 1 — Flask Markup wrapping a concatenated value
# ruleid: xss-prevention
greeting = Markup("<p>Hello " + user_name)

# Pattern 2 — Django mark_safe on a user-controlled variable
# ruleid: xss-prevention
rendered = mark_safe(user_input)

# Pattern 2 — Django mark_safe on another non-literal value
# ruleid: xss-prevention
label = mark_safe(user_name)

# Pattern 3 — Flask Response with non-literal body and text/html content-type
# ruleid: xss-prevention
resp = Response(user_input, content_type="text/html")

# Pattern 3 — Flask Response with text/html mimetype
# ruleid: xss-prevention
resp2 = Response(user_name, mimetype="text/html")

# Pattern 4 — Jinja2 Template built from user input (SSTI + XSS vector)
# ruleid: xss-prevention
result = jinja2.Template(template_str).render(name="world")

# Pattern 4 — Jinja2 Template from user input, rendered with kwargs
# ruleid: xss-prevention
result2 = jinja2.Template(user_input).render()


# ==================== NEGATIVE CASES ====================

# Safe: Markup wrapping a hardcoded string literal — no user input
# ok: xss-prevention
icon = Markup("<span class='icon-ok'></span>")

# Safe: mark_safe on a hardcoded literal — developer-controlled content
# ok: xss-prevention
badge = mark_safe("<span class='badge'>New</span>")

# Safe: Response with a fully hardcoded HTML body
# ok: xss-prevention
static_resp = Response("<html><body>OK</body></html>", content_type="text/html")

# Safe: render_template — Jinja2 auto-escaping is active by default
# ok: xss-prevention
page = render_template("profile.html", user=user_input, data=data)

# Safe: Jinja2 Template from a hardcoded string literal — not user-controlled
# ok: xss-prevention
tmpl = jinja2.Template("<p>{{ value }}</p>").render(value=user_input)

# Safe: Response with JSON content-type — not an HTML injection surface
# ok: xss-prevention
json_resp = Response(user_input, content_type="application/json")
