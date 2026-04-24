status = "completed_with_errors"
name = "administrator"
tags = "prod,staging,dev"

# ruleid: substring-match-without-word-boundary
if "ed" in status:
    print("matched")

# ruleid: substring-match-without-word-boundary
if "ad" in name:
    print("matched")

# ok: substring-match-without-word-boundary
if status == "completed":
    print("exact match")

# ok: substring-match-without-word-boundary
if status.startswith("completed"):
    print("prefix match")

# ok: substring-match-without-word-boundary
if "completed_with_errors" in status:
    print("long substring is more intentional")
