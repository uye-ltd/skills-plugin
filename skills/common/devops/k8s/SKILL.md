---
name: k8s
description: Write production-ready Kubernetes manifests for a service or application.
language: common
used-by: standalone
---

Write Kubernetes manifests for the provided service.

Include as appropriate: Deployment, Service, ConfigMap, Secret (reference only), HPA, Ingress, ServiceAccount, NetworkPolicy.

Best practices:
- Set resource requests and limits on all containers
- Never run as root (`securityContext.runAsNonRoot: true`)
- Use `RollingUpdate` with `maxUnavailable: 0` for zero-downtime deployments
- Add liveness and readiness probes
- Label all resources consistently (`app`, `version`, `component`)

$ARGUMENTS
