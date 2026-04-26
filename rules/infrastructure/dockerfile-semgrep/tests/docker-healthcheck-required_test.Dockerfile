# Tests for KIRBY-INF-022: docker-healthcheck-required
#
# Semgrep annotation format:
#   ruleid:<rule-id>  — expects a finding on the NEXT non-comment instruction
#   ok:<rule-id>      — expects NO finding on the NEXT non-comment instruction

# --- POSITIVE: CMD with no HEALTHCHECK directive anywhere above ---

# ruleid: docker-healthcheck-required
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y curl
USER nonroot
CMD ["app"]

# --- POSITIVE: ENTRYPOINT with no HEALTHCHECK directive ---

# ruleid: docker-healthcheck-required
FROM alpine:3.18
RUN apk add --no-cache bash
USER 1001
ENTRYPOINT ["/bin/bash"]

# --- NEGATIVE: HEALTHCHECK present before CMD ---

# ok: docker-healthcheck-required
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y curl
HEALTHCHECK --interval=30s --timeout=5s CMD curl -f http://localhost/health || exit 1
USER nonroot
CMD ["app"]

# --- NEGATIVE: HEALTHCHECK present before ENTRYPOINT ---

# ok: docker-healthcheck-required
FROM alpine:3.18
RUN apk add --no-cache bash
HEALTHCHECK CMD wget -qO- http://localhost/ping || exit 1
USER 1001
ENTRYPOINT ["/bin/bash"]
