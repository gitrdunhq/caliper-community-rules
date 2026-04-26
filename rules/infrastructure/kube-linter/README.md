# kube-linter — Kubernetes Manifest Security Checks

[kube-linter](https://github.com/stackrox/kube-linter) is a static analysis tool for Kubernetes manifests. It checks YAML files against security and operational best practices before deployment.

## What these checks enforce

| Kirby ID | Name | CIS K8s Control | Severity | Property Domain |
|---|---|---|---|---|
| KIRBY-INF-013 | No root containers | CIS 5.2.6 | HIGH | confidentiality |
| KIRBY-INF-014 | No privileged pods | CIS 5.2.1 | HIGH | confidentiality |

### KIRBY-INF-013 — No root containers

Running containers as root grants UID 0 privileges. If a vulnerability allows container escape, root on the container becomes root on the host node. `runAsNonRoot: true` forces Kubernetes to reject pod startup if the image would run as UID 0.

**Compliance**: CIS K8s Benchmark 5.2.6, NIST AC-6, PCI DSS 7.1.1, ISO 27001 A.5.15

### KIRBY-INF-014 — No privileged pods

Privileged containers bypass almost all container isolation: they have full access to all Linux kernel capabilities, host namespaces, and devices. A privileged container is effectively root on the node. There is almost no legitimate production use case for `privileged: true`.

**Compliance**: CIS K8s Benchmark 5.2.1, NIST AC-6, PCI DSS 7.1.1, ISO 27001 A.5.15

## How to run

```bash
kube-linter lint path/to/manifests --config checks.yaml
```

kube-linter produces JSON output by default when invoked by eedom. To run manually with JSON:

```bash
kube-linter lint k8s/ --config checks.yaml --format json
```

## How eedom integrates kube-linter

eedom invokes `kube-linter lint` as a subprocess, passing `checks.yaml` via `--config`. The JSON output is parsed and each finding is mapped to the eedom severity model using the `severity_map` in `kube-linter.config.yaml`.

Place `kube-linter.config.yaml` in `.eedom/kube-linter.config.yaml` in your repo to configure scanner behaviour (target paths, excluded paths, severity mapping).

### Severity mapping

| kube-linter Severity | eedom Severity |
|---|---|
| CRITICAL | critical |
| HIGH | high |
| MEDIUM | warning |
| LOW | info |

## Files in this directory

| File | Purpose |
|---|---|
| `kube-linter.config.yaml` | eedom plugin configuration (place in `.eedom/`) |
| `checks.yaml` | kube-linter config with Kirby custom check definitions |
| `tests/no-root-containers_pass.yaml` | Compliant Deployment for KIRBY-INF-013 |
| `tests/no-root-containers_fail.yaml` | Non-compliant Deployment for KIRBY-INF-013 |
| `tests/no-privileged-pods_pass.yaml` | Compliant Deployment for KIRBY-INF-014 |
| `tests/no-privileged-pods_fail.yaml` | Non-compliant Deployment for KIRBY-INF-014 |

## Remediation examples

**KIRBY-INF-013 — Add `runAsNonRoot`:**

```yaml
spec:
  template:
    spec:
      securityContext:
        runAsNonRoot: true
      containers:
        - name: app
          securityContext:
            runAsNonRoot: true
```

**KIRBY-INF-014 — Remove `privileged` or set it to false:**

```yaml
spec:
  template:
    spec:
      containers:
        - name: app
          securityContext:
            privileged: false   # or omit the field entirely
```

## References

- [kube-linter on GitHub](https://github.com/stackrox/kube-linter)
- [kube-linter custom checks documentation](https://docs.kubelinter.io/#/generating-checks)
- [CIS Kubernetes Benchmark](https://www.cisecurity.org/benchmark/kubernetes)
- [NIST SP 800-190 — Application Container Security Guide](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-190.pdf)
