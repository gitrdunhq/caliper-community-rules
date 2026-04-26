# Dockerfile Semgrep Rules — CIS Docker Benchmark (Wave 3)

Semgrep rules for Dockerfile best-practices, mapped to the CIS Docker Benchmark v1.6.
This is Kirby's first Dockerfile scanner.

## What These Rules Check

| Kirby ID | Rule File | CIS Control | Severity | Property Domain | Description |
|---|---|---|---|---|---|
| KIRBY-INF-020 | `docker-user-directive.yaml` | 4.1 | WARNING | confidentiality | Container must set a non-root USER directive |
| KIRBY-INF-021 | `docker-copy-over-add.yaml` | 4.9 | INFO | integrity | Use COPY instead of ADD to reduce supply chain risk |
| KIRBY-INF-022 | `docker-healthcheck-required.yaml` | 4.6 | WARNING | availability | Container must define a HEALTHCHECK instruction |

## How to Run

Scan a single Dockerfile:

```bash
semgrep --config rules/infrastructure/dockerfile-semgrep/ path/to/Dockerfile
```

Scan all Dockerfiles under a directory tree:

```bash
semgrep --config rules/infrastructure/dockerfile-semgrep/ --include="Dockerfile*" .
```

Run tests (requires Semgrep's test mode):

```bash
semgrep --test rules/infrastructure/dockerfile-semgrep/
```

## Rule Details

### KIRBY-INF-020 — Docker USER Directive Required

Running containers as root grants them unnecessary host privileges.  
If a compromised process inside the container escalates, root inside the container
maps directly to root on the host (absent user-namespace remapping).

**Fix:** Add `USER nonroot` (or a numeric UID such as `USER 1001`) after package
installation and before your `CMD`/`ENTRYPOINT`.

### KIRBY-INF-021 — Docker COPY Over ADD

`ADD` silently auto-extracts `.tar` archives and can pull remote URLs at build
time, making the build non-reproducible and introducing a supply chain fetch that
is not pinned or verified.

**Fix:** Replace `ADD src dst` with `COPY src dst`. For remote resources, use an
explicit `RUN curl -fsSL <url> | sha256sum -c <expected> && ...` pipeline so the
checksum is visible and reviewable.

### KIRBY-INF-022 — Docker HEALTHCHECK Required

Without a `HEALTHCHECK`, orchestrators like Kubernetes, ECS, and Swarm cannot
distinguish a started-but-broken container from a healthy one.  Unhealthy
containers stay in rotation and silently serve errors.

**Fix:** Add a `HEALTHCHECK` instruction, for example:

```dockerfile
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD curl -f http://localhost/health || exit 1
```

## References

- [CIS Docker Benchmark v1.6](https://www.cisecurity.org/benchmark/docker)
- [Docker Dockerfile reference](https://docs.docker.com/reference/dockerfile/)
- [Semgrep Dockerfile language support](https://semgrep.dev/docs/writing-rules/rule-syntax/#language-extensions-and-languages-key-values)
