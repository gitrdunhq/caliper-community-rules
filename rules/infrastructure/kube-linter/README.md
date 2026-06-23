# kube-linter — Kubernetes Manifest Security Checks

[kube-linter](https://github.com/stackrox/kube-linter) is a static analysis tool for Kubernetes manifests. It checks YAML files against security and operational best practices before deployment.

## What these checks enforce

| Kirby ID | Name | CIS K8s Control | Severity | Property Domain |
|---|---|---|---|---|
| KIRBY-INF-013 | No root containers | CIS 5.2.6 | HIGH | confidentiality |
| KIRBY-INF-014 | No privileged pods | CIS 5.2.1 | HIGH | confidentiality |
| KIRBY-INF-016 | Drop all capabilities | CIS 5.2.7 | MEDIUM | confidentiality |
| KIRBY-INF-017 | No default namespace | CIS 5.7.4 | MEDIUM | isolation |
| KIRBY-INF-018 | Read-only root filesystem | CIS 5.2.4 | MEDIUM | integrity |
| KIRBY-INF-019 | Resource limits required | CIS 5.4.1 | MEDIUM | boundedness |

### KIRBY-INF-013 — No root containers

Running containers as root grants UID 0 privileges. If a vulnerability allows container escape, root on the container becomes root on the host node. `runAsNonRoot: true` forces Kubernetes to reject pod startup if the image would run as UID 0.

**Compliance**: CIS K8s Benchmark 5.2.6, NIST AC-6, PCI DSS 7.1.1, ISO 27001 A.5.15

### KIRBY-INF-014 — No privileged pods

Privileged containers bypass almost all container isolation: they have full access to all Linux kernel capabilities, host namespaces, and devices. A privileged container is effectively root on the node. There is almost no legitimate production use case for `privileged: true`.

**Compliance**: CIS K8s Benchmark 5.2.1, NIST AC-6, PCI DSS 7.1.1, ISO 27001 A.5.15

### KIRBY-INF-016 — Drop all capabilities

Linux capabilities grant fine-grained kernel privileges. Containers inherit a default set that includes `NET_RAW` (used in network sniffing and ICMP-based attacks) and others. Dropping `ALL` and adding back only what the workload needs enforces least-privilege at the kernel level and drastically reduces the exploit surface for privilege-escalation attacks.

**Compliance**: CIS K8s Benchmark 5.2.7, NIST AC-6

### KIRBY-INF-017 — No default namespace

The `default` namespace has no access controls by default. Deploying workloads there means they share an administrative boundary with any other workload that also ends up in `default`. Dedicated namespaces allow RBAC, NetworkPolicy, and ResourceQuota to be scoped to a team or service boundary.

**Compliance**: CIS K8s Benchmark 5.7.4, NIST AC-6

### KIRBY-INF-018 — Read-only root filesystem

A writable root filesystem lets an attacker who achieves RCE inside a container modify binaries, install persistence tools (cron, backdoors), or write web shells. Setting `readOnlyRootFilesystem: true` turns the container's root into a read-only layer; any paths that legitimately need writes (e.g. `/tmp`, `/var/run`) are mounted explicitly via `emptyDir` volumes and are therefore auditable and ephemeral.

**Compliance**: CIS K8s Benchmark 5.2.4, NIST AC-6

### KIRBY-INF-019 — Resource limits required

Without CPU and memory limits a single misbehaving or compromised container can consume all resources on a node, causing OOM kills and CPU starvation for co-located workloads. The check is split into two kube-linter rules (`cpu-limits-required` and `memory-limits-required`) because the templates are separate, but both must pass for KIRBY-INF-019 to be considered compliant.

**Compliance**: CIS K8s Benchmark 5.4.1, NIST SC-6

## How to run

```bash
kube-linter lint path/to/manifests --config checks.yaml
```

kube-linter produces JSON output by default when invoked by caliper. To run manually with JSON:

```bash
kube-linter lint k8s/ --config checks.yaml --format json
```

## How Caliper integrates kube-linter

Caliper invokes `kube-linter lint` as a subprocess, passing `checks.yaml` via `--config`. The JSON output is parsed and each finding is mapped to the caliper severity model using the `severity_map` in `kube-linter.config.yaml`.

Place `kube-linter.config.yaml` in `.caliper/kube-linter.config.yaml` in your repo to configure scanner behaviour (target paths, excluded paths, severity mapping).

### Severity mapping

| kube-linter Severity | caliper Severity |
|---|---|
| CRITICAL | critical |
| HIGH | high |
| MEDIUM | warning |
| LOW | info |

## Files in this directory

| File | Purpose |
|---|---|
| `kube-linter.config.yaml` | caliper plugin configuration (place in `.caliper/`) |
| `checks.yaml` | kube-linter config with Kirby custom check definitions |
| `tests/no-root-containers_pass.yaml` | Compliant Deployment for KIRBY-INF-013 |
| `tests/no-root-containers_fail.yaml` | Non-compliant Deployment for KIRBY-INF-013 |
| `tests/no-privileged-pods_pass.yaml` | Compliant Deployment for KIRBY-INF-014 |
| `tests/no-privileged-pods_fail.yaml` | Non-compliant Deployment for KIRBY-INF-014 |
| `tests/drop-all-capabilities_pass.yaml` | Compliant Deployment for KIRBY-INF-016 |
| `tests/drop-all-capabilities_fail.yaml` | Non-compliant Deployment for KIRBY-INF-016 |
| `tests/no-default-namespace_pass.yaml` | Compliant Deployment for KIRBY-INF-017 |
| `tests/no-default-namespace_fail.yaml` | Non-compliant Deployment for KIRBY-INF-017 |
| `tests/read-only-root-fs_pass.yaml` | Compliant Deployment for KIRBY-INF-018 |
| `tests/read-only-root-fs_fail.yaml` | Non-compliant Deployment for KIRBY-INF-018 |
| `tests/resource-limits_pass.yaml` | Compliant Deployment for KIRBY-INF-019 (CPU + memory) |
| `tests/resource-limits_fail.yaml` | Non-compliant Deployment for KIRBY-INF-019 (no limits) |

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

**KIRBY-INF-016 — Drop ALL capabilities, add back only what's needed:**

```yaml
spec:
  template:
    spec:
      containers:
        - name: app
          securityContext:
            capabilities:
              drop:
                - ALL
              add:
                - NET_BIND_SERVICE   # only if the container needs port <1024
```

**KIRBY-INF-017 — Deploy to a dedicated namespace:**

```yaml
metadata:
  name: my-service
  namespace: my-team   # never "default"
```

**KIRBY-INF-018 — Set `readOnlyRootFilesystem` and mount writable paths:**

```yaml
spec:
  template:
    spec:
      containers:
        - name: app
          securityContext:
            readOnlyRootFilesystem: true
          volumeMounts:
            - name: tmp
              mountPath: /tmp
      volumes:
        - name: tmp
          emptyDir: {}
```

**KIRBY-INF-019 — Set CPU and memory limits:**

```yaml
spec:
  template:
    spec:
      containers:
        - name: app
          resources:
            requests:
              cpu: "100m"
              memory: "128Mi"
            limits:
              cpu: "500m"
              memory: "256Mi"
```

## References

- [kube-linter on GitHub](https://github.com/stackrox/kube-linter)
- [kube-linter custom checks documentation](https://docs.kubelinter.io/#/generating-checks)
- [CIS Kubernetes Benchmark](https://www.cisecurity.org/benchmark/kubernetes)
- [NIST SP 800-190 — Application Container Security Guide](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-190.pdf)
