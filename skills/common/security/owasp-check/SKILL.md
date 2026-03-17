---
name: owasp-check
description: Review code against the OWASP Top 10 vulnerabilities. Use for security audits of web services, APIs, or any code handling untrusted input.
language: common
used-by: reviewer,standalone
---

Review the provided code against the OWASP Top 10 (2021).

Check for each category:

1. **Broken Access Control** — missing authorisation checks, IDOR, path traversal
2. **Cryptographic Failures** — weak algorithms, no encryption at rest/transit, hardcoded keys
3. **Injection** — SQL, NoSQL, OS command, LDAP injection via unsanitised input
4. **Insecure Design** — missing rate limiting, no abuse prevention, insecure defaults
5. **Security Misconfiguration** — debug mode in prod, default credentials, verbose errors
6. **Vulnerable Components** — outdated dependencies with known CVEs (flag versions to check)
7. **Authentication Failures** — weak passwords allowed, no MFA, broken session management
8. **Integrity Failures** — unverified deserialization, unsigned updates, unsafe YAML/pickle
9. **Logging Failures** — insufficient logging of security events, PII in logs
10. **SSRF** — user-controlled URLs fetched by the server without validation

Output: findings grouped by OWASP category with severity (critical / high / medium / low), file:line, and concrete remediation.

$ARGUMENTS
