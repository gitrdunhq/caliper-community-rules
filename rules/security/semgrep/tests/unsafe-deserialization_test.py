"""
Semgrep test file for unsafe-deserialization (KIRBY-SEC-010).

Positive cases are annotated with:  # ruleid: unsafe-deserialization
Negative cases are annotated with:  # ok: unsafe-deserialization

Run with:
  semgrep --test rules/security/semgrep/unsafe-deserialization.yaml \
          rules/security/semgrep/tests/unsafe-deserialization_test.py
"""

import io
import json
import marshal
import pickle
import shelve
import yaml

# Stub values — obviously fake, no real credentials or secrets.
raw_bytes = b"test_bytes"
file_path = "test_file.pkl"
yaml_string = "key: value"
shelf_path = "test_shelf"


# ==================== POSITIVE CASES ====================
# These must each trigger the rule exactly once.

# Pattern 1 — pickle.load from a file object
# ruleid: unsafe-deserialization
with open(file_path, "rb") as f:
    obj = pickle.load(f)

# Pattern 2 — pickle.loads from raw bytes
# ruleid: unsafe-deserialization
obj = pickle.loads(raw_bytes)

# Pattern 3 — yaml.load with FullLoader (not safe for untrusted input)
# ruleid: unsafe-deserialization
data = yaml.load(yaml_string, Loader=yaml.FullLoader)

# Pattern 4 — yaml.load with no Loader argument (uses unsafe default pre-5.1)
# ruleid: unsafe-deserialization
data = yaml.load(yaml_string)

# Pattern 5 — marshal.load from a file object
# ruleid: unsafe-deserialization
with open(file_path, "rb") as f:
    obj = marshal.load(f)

# Pattern 6 — shelve.open (uses pickle internally for values)
# ruleid: unsafe-deserialization
db = shelve.open(shelf_path)

# Pattern 7 — pickle.loads with BytesIO (bytes from an untrusted source)
# ruleid: unsafe-deserialization
obj = pickle.loads(io.BytesIO(raw_bytes).read())

# Pattern 8 — yaml.load with UnsafeLoader (explicitly unsafe)
# ruleid: unsafe-deserialization
data = yaml.load(yaml_string, Loader=yaml.UnsafeLoader)


# ==================== NEGATIVE CASES ====================
# These must NOT trigger the rule.

# Safe — yaml.safe_load restricts types to Python primitives
# ok: unsafe-deserialization
data = yaml.safe_load(yaml_string)

# Safe — yaml.load with SafeLoader explicitly specified
# ok: unsafe-deserialization
data = yaml.load(yaml_string, Loader=yaml.SafeLoader)

# Safe — yaml.load with CSafeLoader (C-accelerated SafeLoader)
# ok: unsafe-deserialization
data = yaml.load(yaml_string, Loader=yaml.CSafeLoader)

# Safe — json.loads has no code-execution attack surface
# ok: unsafe-deserialization
data = json.loads('{"key": "value"}')

# Safe — json.load from a file has no code-execution attack surface
# ok: unsafe-deserialization
with open("test_config.json") as f:
    config = json.load(f)

# Safe — yaml.safe_load_all for multi-document YAML streams
# ok: unsafe-deserialization
docs = list(yaml.safe_load_all(yaml_string))
