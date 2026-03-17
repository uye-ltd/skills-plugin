---
name: owasp-check
description: Review infrastructure, API boundaries, and deployment configuration against the OWASP Top 10. Covers infra-level misconfiguration, vulnerable components, auth failures in config, and SSRF at the network boundary. For code-level injection and cryptographic failures in source code, use the language-specific code-review skill.
language: common
used-by: reviewer,standalone
---

Review the provided infrastructure, API, and configuration artefacts against the OWASP Top 10 (2021) at the infrastructure and API boundary level.

**Scope**: infra/API boundary — deployment config, HTTP layer, dependencies, network-level auth.
**Out of scope**: code-level injection (cat. 3) and cryptographic failures in source code (cat. 2) — use the language-specific `code-review` skill for those.

Check for each in-scope category:

4. **Insecure Design** — missing rate limiting, no abuse prevention, insecure defaults, lack of defence in depth
5. **Security Misconfiguration** — debug mode in production, default credentials, verbose error responses, unnecessary features enabled, missing security headers (CSP, HSTS, X-Frame-Options)
6. **Vulnerable Components** — outdated dependencies with known CVEs; flag package names and versions to check against advisories
7. **Authentication Failures** — weak password policies, missing MFA, broken session management, insecure token storage
10. **SSRF** — user-controlled URLs fetched by the server without allowlist validation; internal metadata endpoint exposure

Also check:
- **Broken Access Control** (cat. 1) — at the API/gateway level: missing authorisation on routes, insecure direct object references via URL parameters, path traversal in file-serving routes
- **Logging Failures** (cat. 9) — insufficient logging of authentication events, PII in logs, missing audit trail for privileged operations

Output: findings grouped by OWASP category with severity (critical / high / medium / low), location (file:line or config key), and concrete remediation.

$ARGUMENTS
