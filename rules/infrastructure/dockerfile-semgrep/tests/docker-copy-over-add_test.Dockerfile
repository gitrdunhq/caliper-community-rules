# Tests for KIRBY-INF-021: docker-copy-over-add
#
# Semgrep annotation format:
#   ruleid:<rule-id>  — expects a finding on the NEXT non-comment instruction
#   ok:<rule-id>      — expects NO finding on the NEXT non-comment instruction

# --- POSITIVE: ADD used for a local archive (should use COPY instead) ---

FROM ubuntu:22.04
# ruleid: docker-copy-over-add
ADD app.tar.gz /usr/src/app/

# --- POSITIVE: ADD used for a remote URL ---

FROM ubuntu:22.04
# ruleid: docker-copy-over-add
ADD https://example.com/config.json /etc/app/config.json

# --- NEGATIVE: COPY used for local file ---

FROM ubuntu:22.04
# ok: docker-copy-over-add
COPY app.tar.gz /usr/src/app/

# --- NEGATIVE: COPY used for a directory ---

FROM ubuntu:22.04
# ok: docker-copy-over-add
COPY ./src /usr/src/app/
