# Kirby Roadmap — 60 Scanner Rules in 5 Waves

## Framework Coverage Matrix

| Wave | Rules | OWASP | CIS | NIST | SOC2 | PCI | HIPAA | ISO 27001 |
|------|-------|-------|-----|------|------|-----|-------|-----------|
| 1 — Foundation | 12 | 8 | 8 | 10 | 8 | 8 | 6 | 6 |
| 2 — Security Critical | 10 | 8 | 2 | 4 | 2 | 6 | 4 | 4 |
| 3 — Infra Hardening | 14 | 0 | 12 | 8 | 6 | 4 | 4 | 4 |
| 4 — App Security | 14 | 14 | 0 | 4 | 2 | 6 | 2 | 2 |
| 5 — Compliance Completeness | 10 | 2 | 6 | 6 | 6 | 4 | 4 | 4 |
| **Total** | **60** | **32** | **28** | **32** | **24** | **28** | **20** | **20** |

---

## Wave 1: Foundation (12 rules)

Rules satisfying 3+ frameworks. Maximum compliance ROI per implementation.

| Kirby ID | Rule | Scanner | Frameworks | Severity | Effort | Target |
|----------|------|---------|------------|----------|--------|--------|
| KIRBY-SEC-005 | Hardcoded credentials detection | Semgrep + Bandit | OWASP A07, CIS, NIST IA-5(7)/CM-6, SOC2, PCI, HIPAA, ISO | Critical | M | Python, Java, Go, JS/TS |
| KIRBY-INF-008 | S3 bucket encryption | tfsec | CIS 2.1.1, NIST SC-28, SOC2 CC6.1, PCI 3.4, HIPAA, ISO | High | S | Terraform, CFN |
| KIRBY-INF-005† | S3 public access block | tfsec | CIS 2.1.5, OWASP, NIST AC-6, SOC2 CC6.1, PCI | High | S | Terraform, CFN |
| KIRBY-INF-009 | Security group SSH lockdown (no 0.0.0.0/0 on 22) | tfsec + cfn-nag | CIS 5.2, OWASP, NIST AC-6, SOC2 CC6.1, PCI | High | S | Terraform, CFN |
| KIRBY-SEC-006 | No root access keys | tfsec + Bandit | CIS 1.4, NIST AC-6(2), SOC2, PCI, ISO | Critical | S | Terraform, Python |
| KIRBY-INF-010 | VPC flow logs enabled | tfsec | CIS 3.9, NIST AU-2/AU-3, SOC2 CC7.2, PCI 10 | High | S | Terraform, CFN |
| KIRBY-INF-006† | RDS encryption at rest | tfsec | CIS 2.3.1, NIST SC-28, SOC2, PCI 3.4, HIPAA | High | S | Terraform, CFN |
| KIRBY-INF-011 | EBS encryption enabled | tfsec | CIS 2.2.1, NIST SC-28, AWS WA, PCI 3.4, HIPAA | High | S | Terraform, CFN |
| KIRBY-INF-012 | CloudTrail enabled in all regions | tfsec | CIS 3.1, NIST AU-2/AU-3, SOC2, PCI 10, ISO | High | M | Terraform, CFN |
| KIRBY-SEC-007 | Encryption in transit (TLS config) | Semgrep + tfsec | OWASP A02, NIST SC-8, SOC2, PCI 4.1, HIPAA, ISO | High | M | Terraform, Python, Java, Go, JS/TS |
| KIRBY-INF-013 | No root containers (K8s) | kube-linter + OPA | CIS 5.2.6, NIST AC-6, AWS WA, PCI, ISO | High | S | K8s manifests, Helm |
| KIRBY-INF-014 | No privileged pods | kube-linter + OPA | CIS 5.2.1, NIST AC-6, AWS WA, PCI, ISO | High | S | K8s manifests, Helm |

† Extends existing rule to additional scanner/IaC format.

**Wave 1 totals**: 12 rules, ~90 framework-compliance checkboxes. Estimated calendar: 2-3 weeks.

---

## Wave 2: Security Critical (10 rules)

Critical/high severity rules not covered by Wave 1. Application-layer attack surface.

| Kirby ID | Rule | Scanner | Frameworks | Severity | Effort | Target |
|----------|------|---------|------------|----------|--------|--------|
| KIRBY-SEC-008 | SQL injection | Semgrep | OWASP A03, PCI 6.5, HIPAA | Critical | M | Python, Java, Go, JS/TS |
| KIRBY-SEC-009 | Command injection | Semgrep + Bandit | OWASP A03, NIST SI-10, PCI 6.5 | Critical | M | Python, Java, Go, JS/TS |
| KIRBY-SEC-010 | Unsafe deserialization (pickle, yaml.load) | Bandit + Semgrep | OWASP A08, NIST SI-10, PCI 6.5 | Critical | S | Python, Java |
| KIRBY-SEC-011 | JWT verification bypass | Semgrep | OWASP A07, NIST IA-2, PCI 8 | Critical | M | Python, Java, Go, JS/TS |
| KIRBY-SEC-012 | XSS (cross-site scripting) | Semgrep | OWASP A03, PCI 6.5, HIPAA | High | M | JS/TS, Java, Python |
| KIRBY-SEC-013 | SSRF (server-side request forgery) | Semgrep | OWASP A10, NIST SI-10, PCI 6.5 | High | M | Python, Java, Go, JS/TS |
| KIRBY-SEC-014 | Path traversal | Semgrep | OWASP A01, NIST SI-10, PCI 6.5 | High | M | Python, Java, Go, JS/TS |
| KIRBY-SEC-015 | XML external entity (XXE) | Semgrep | OWASP A05, NIST SI-10, PCI 6.5 | High | M | Python, Java, Go |
| KIRBY-SEC-016 | Weak crypto MD5/SHA1 | Bandit + Semgrep | OWASP A02, NIST SC-13, PCI 4, ISO | High | S | Python, Java, Go, JS/TS |
| KIRBY-INF-015 | Public S3 buckets (ACL-based) | tfsec | OWASP A01, CIS 2.1.5, NIST AC-6 | Critical | S | Terraform, CFN |

**Wave 2 totals**: 10 rules. Estimated calendar: 2-3 weeks.

---

## Wave 3: Infrastructure Hardening (14 rules)

IaC-focused rules covering CIS benchmarks and cloud posture.

| Kirby ID | Rule | Scanner | Frameworks | Severity | Effort | Target |
|----------|------|---------|------------|----------|--------|--------|
| KIRBY-INF-016 | K8s drop all capabilities | kube-linter + OPA | CIS 5.2.7, NIST AC-6 | Medium | S | K8s manifests, Helm |
| KIRBY-INF-017 | K8s no default namespace | kube-linter + OPA | CIS 5.7.4, NIST AC-6 | Medium | S | K8s manifests |
| KIRBY-INF-018 | K8s read-only root filesystem | kube-linter + OPA | CIS 5.2.4, NIST AC-6 | Medium | S | K8s manifests, Helm |
| KIRBY-INF-019 | K8s resource limits required | kube-linter + OPA | CIS 5.4.1, AWS WA | Medium | S | K8s manifests, Helm |
| KIRBY-INF-020 | Docker USER directive required | Trivy + Semgrep | CIS Docker 4.1, NIST AC-6 | Medium | S | Dockerfile |
| KIRBY-INF-021 | Docker COPY over ADD | Trivy + Semgrep | CIS Docker 4.9 | Low | S | Dockerfile |
| KIRBY-INF-022 | Docker HEALTHCHECK required | Trivy + Semgrep | CIS Docker 4.6, AWS WA | Medium | S | Dockerfile |
| KIRBY-INF-023 | Azure storage public access disabled | tfsec | CIS Azure 3.1, NIST AC-6, SOC2 | High | S | Terraform |
| KIRBY-INF-024 | Azure NSG SSH lockdown | tfsec | CIS Azure 6.2, NIST AC-6, SOC2 | High | S | Terraform |
| KIRBY-INF-025 | GCP no default service account | tfsec | CIS GCP 4.1, NIST AC-6(1) | High | S | Terraform |
| KIRBY-INF-026 | Multi-AZ RDS | tfsec + cfn-nag | AWS WA, SOC2 A1.2, NIST CP-10 | Medium | S | Terraform, CFN |
| KIRBY-INF-002† | RDS backups enabled | tfsec + cfn-nag | SOC2 A1.2, NIST CP-9, HIPAA | Medium | S | Terraform, CFN |
| KIRBY-INF-027 | Lambda dead letter queue | tfsec + cfn-nag | AWS WA, NIST AU-2 | Medium | S | Terraform, CFN |
| KIRBY-INF-028 | ElastiCache encryption in transit | tfsec | AWS WA, NIST SC-8, PCI 4.1 | Medium | S | Terraform, CFN |

† Extends existing rule to additional scanner/IaC format.

**Wave 3 totals**: 14 rules. Estimated calendar: 2 weeks.

---

## Wave 4: Application Security (14 rules)

Code-level rules targeting language-specific vulnerabilities.

| Kirby ID | Rule | Scanner | Frameworks | Severity | Effort | Target |
|----------|------|---------|------------|----------|--------|--------|
| KIRBY-SEC-017 | Debug mode in production | Semgrep | OWASP A05, NIST CM-6 | High | S | Python (Django/Flask), JS/TS |
| KIRBY-SEC-018 | Open redirect | Semgrep | OWASP A01, PCI 6.5 | Medium | M | Python, Java, Go, JS/TS |
| KIRBY-SEC-019 | CORS wildcard origin | Semgrep | OWASP A05, PCI 6.5 | Medium | S | Python, Java, Go, JS/TS |
| KIRBY-SEC-020 | Missing rate limiting | Semgrep | OWASP A04, NIST SC-5 | Medium | L | Python, Java, Go, JS/TS |
| KIRBY-SEC-021 | CSRF token missing | Semgrep | OWASP A01, PCI 6.5 | High | M | Python (Django), Java, JS/TS |
| KIRBY-SEC-022 | Mass assignment / over-posting | Semgrep | OWASP A04, PCI 6.5 | Medium | M | Python, Java, JS/TS |
| KIRBY-SEC-023 | Verbose error exposure in production | Semgrep | OWASP A05, NIST SI-11 | Medium | S | Python, Java, Go, JS/TS |
| KIRBY-SEC-024 | Insecure file permissions (0777, 0666) | Bandit + Semgrep | OWASP A01, NIST AC-6 | Medium | S | Python, Go |
| KIRBY-SEC-025 | os.system() usage | Bandit | OWASP A03, NIST SI-10 | High | S | Python |
| KIRBY-SEC-026 | subprocess shell=True | Bandit + Semgrep | OWASP A03, NIST SI-10 | High | S | Python |
| KIRBY-SEC-027 | eval() usage | Semgrep | OWASP A03, NIST SI-10 | High | S | Python, JS/TS |
| KIRBY-SEC-028 | Insecure TLS version (< 1.2) | Semgrep | OWASP A02, NIST SC-8, PCI 4.1 | High | S | Python, Java, Go, JS/TS |
| KIRBY-SEC-029 | Unsafe yaml.load without Loader | Bandit + Semgrep | OWASP A08 | High | S | Python |
| KIRBY-SEC-030 | pickle.loads on untrusted data | Bandit + Semgrep | OWASP A08 | High | S | Python |

**Wave 4 totals**: 14 rules. Estimated calendar: 3 weeks.

---

## Wave 5: Compliance Completeness (10 rules)

Remaining rules to achieve full framework coverage matrices.

| Kirby ID | Rule | Scanner | Frameworks | Severity | Effort | Target |
|----------|------|---------|------------|----------|--------|--------|
| KIRBY-INF-029 | MFA enforcement on root/admin | tfsec + cfn-nag | NIST IA-2(1), CIS 1.5, PCI 8.3, HIPAA | High | M | Terraform, CFN |
| KIRBY-INF-030 | Log encryption (CloudWatch, S3 logs) | tfsec | NIST AU-9, SOC2 CC6.1, HIPAA | Medium | S | Terraform, CFN |
| KIRBY-INF-003† | CloudWatch log retention policy | tfsec + cfn-nag | AWS WA, NIST AU-11, SOC2, PCI 10.7 | Medium | S | Terraform, CFN |
| KIRBY-INF-004† | Least privilege IAM policies (no *) | tfsec + cfn-nag | NIST AC-6(1), CIS 1.16, SOC2, PCI 7.1 | High | L | Terraform, CFN |
| KIRBY-INF-031 | No public RDS instances | tfsec | SOC2 CC6.1, NIST AC-6, CIS 2.3.2 | High | S | Terraform, CFN |
| KIRBY-INF-032 | KMS key rotation enabled | tfsec | CIS 3.8, NIST SC-12, PCI 3.6, HIPAA | Medium | S | Terraform, CFN |
| KIRBY-INF-001† | S3 versioning enabled | tfsec | NIST CP-9, SOC2 A1.2 | Low | S | Terraform, CFN |
| KIRBY-INF-033 | SNS topic encryption | tfsec | NIST SC-28, SOC2 CC6.1 | Medium | S | Terraform, CFN |
| KIRBY-INF-034 | SQS queue encryption | tfsec | NIST SC-28, SOC2 CC6.1 | Medium | S | Terraform, CFN |
| KIRBY-SCM-001 | ECR image scan on push | Trivy + tfsec | AWS WA, NIST SI-2, SOC2 | Medium | S | Terraform, CFN |

† Extends existing rule to additional scanner/IaC format.

**Wave 5 totals**: 10 rules. Estimated calendar: 2 weeks.

---

## ID Allocation Summary

| Category | Existing (shipped) | Roadmap (new) | Roadmap (extends) | Total unique |
|----------|--------------------|---------------|--------------------|--------------|
| SEC | SEC-001 — SEC-004 | SEC-005 — SEC-030 | — | 30 |
| INF | INF-001 — INF-007 | INF-008 — INF-034 | INF-001†, INF-002†, INF-003†, INF-004†, INF-005†, INF-006† | 34 |
| SCM | — | SCM-001 | — | 1 |
| QUA | QUA-001 — QUA-002 | — | — | 2 |
| STD | STD-001 | — | — | 1 |
| **Total** | **14** | **53** | **6 extends** | **68 unique IDs** |

## Effort Summary

| Effort | Count | Definition |
|--------|-------|------------|
| S | 42 | Single-pattern rule, < 1 day |
| M | 14 | Multi-pattern or multi-language, 1-2 days |
| L | 4 | Complex detection logic or framework integration, 2-3 days |

## Severity Distribution

| Severity | Count |
|----------|-------|
| Critical | 8 |
| High | 32 |
| Medium | 17 |
| Low | 3 |

## Scanner Distribution

| Scanner | Primary Rules | Supporting Role |
|---------|--------------|-----------------|
| Semgrep | 26 | 8 |
| tfsec | 22 | 4 |
| Bandit | 6 | 6 |
| kube-linter + OPA | 6 | 0 |
| cfn-nag | 0 | 8 |
| Trivy | 3 | 1 |

## Estimated Total Calendar

| Wave | Duration | Cumulative |
|------|----------|------------|
| Wave 1 — Foundation | 2-3 weeks | 2-3 weeks |
| Wave 2 — Security Critical | 2-3 weeks | 4-6 weeks |
| Wave 3 — Infra Hardening | 2 weeks | 6-8 weeks |
| Wave 4 — App Security | 3 weeks | 9-11 weeks |
| Wave 5 — Compliance Completeness | 2 weeks | 11-13 weeks |
