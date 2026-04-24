import json

# ruleid: missing-oserror-on-file-open
f = open("config.json", "r")
data = json.load(f)
f.close()

# ruleid: missing-oserror-on-file-open
content = open("/etc/passwd", "r").read()

# ok: missing-oserror-on-file-open
try:
    f = open("config.json", "r")
    data = json.load(f)
except OSError:
    data = {}

# ok: missing-oserror-on-file-open
try:
    f = open("config.json", "r")
    data = json.load(f)
except FileNotFoundError:
    data = {}

# ok: missing-oserror-on-file-open
with open("config.json", "r") as f:
    data = json.load(f)
