#!/bin/bash

# ruleid: verify-gate-fails-open
if [ -z "$VERIFICATION_STATUS" ]; then
  echo "No verification status found"
  exit 0
fi

# ruleid: verify-gate-fails-open
gh api /repos/owner/repo/statuses/abc123 || exit 0

# ruleid: verify-gate-fails-open
cosign verify image:tag || true

# ok: verify-gate-fails-open
if [ -z "$VERIFICATION_STATUS" ]; then
  echo "No verification status found"
  exit 1
fi

# ok: verify-gate-fails-open
gh api /repos/owner/repo/statuses/abc123 || exit 1

# ok: verify-gate-fails-open
cosign verify image:tag
