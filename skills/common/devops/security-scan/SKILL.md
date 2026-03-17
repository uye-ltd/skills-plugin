---
name: security-scan
description: Security review of infrastructure configuration (Dockerfiles, Kubernetes manifests, CI configs, Terraform, shell scripts).
language: common
used-by: standalone
---

Perform a security-focused review of the provided infrastructure configuration.

Check for: secrets exposure, privilege escalation (root containers, broad RBAC), unnecessary network exposure, unpinned/vulnerable images, supply chain risks (unpinned action versions), least-privilege violations, missing audit logging, outdated dependencies with known CVEs.

Output:
1. Risk summary (critical / high / medium / low counts)
2. Findings list with severity, description, and remediation
3. Prioritised action plan

$ARGUMENTS
