# Infrastructure Rules

Rules that detect misconfigurations in Kubernetes manifests, Docker images, and IaC templates.

## Threat model

Infrastructure misconfigurations are the #1 cause of cloud breaches. Running as root, missing resource limits, exposed ports, and missing network policies all create attack surface. These rules catch them before deployment.

## What belongs here

- **Kubernetes** -- missing resource limits, privileged containers, missing probes
- **Docker** -- running as root, ADD vs COPY, missing health checks
- **IaC** -- Terraform/CloudFormation misconfigurations
- **Malware** -- custom signatures for known malicious patterns in artifacts

## Scanners

| Directory | Scanner | File format |
|-----------|---------|-------------|
| `cfn-nag/` | cfn_nag | `.rb` custom rules |
| `cdk-nag/` | cdk-nag | `.ts` examples + `.yaml` config |
| `tfsec/` | tfsec | `.json` custom rules + `.yaml` config |
| `kube-linter/` | kube-linter | `.yaml` check configs |
| `clamav/` | ClamAV | `.ndb` / `.ldb` custom signatures |
