# Tests for KIRBY-INF-020: docker-user-directive-required
#
# Semgrep annotation format:
#   ruleid:<rule-id>  — expects a finding on the NEXT non-comment instruction
#   ok:<rule-id>      — expects NO finding on the NEXT non-comment instruction

# --- POSITIVE: CMD with no USER directive present anywhere above it ---

# ruleid: docker-user-directive-required
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y curl
CMD ["app"]

# --- POSITIVE: ENTRYPOINT with no USER directive ---

# ruleid: docker-user-directive-required
FROM alpine:3.18
RUN apk add --no-cache bash
ENTRYPOINT ["/bin/bash"]

# --- NEGATIVE: USER directive present before CMD ---

# ok: docker-user-directive-required
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y curl
USER nonroot
CMD ["app"]

# --- NEGATIVE: USER directive present before ENTRYPOINT ---

# ok: docker-user-directive-required
FROM alpine:3.18
RUN apk add --no-cache bash
USER 1001
ENTRYPOINT ["/bin/bash"]
