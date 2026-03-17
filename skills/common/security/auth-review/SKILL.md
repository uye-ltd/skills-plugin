---
name: auth-review
description: Review authentication and authorisation code. Use when auditing login flows, session management, JWT handling, RBAC, or permission checks.
language: common
used-by: reviewer,standalone
---

Review the provided authentication and authorisation code.

**Authentication** — check:
- Password hashing: uses bcrypt/argon2/scrypt (not MD5/SHA1/plain)
- Brute-force protection: rate limiting, account lockout, or CAPTCHA
- Session management: secure + httpOnly cookies, proper expiry, invalidation on logout
- JWT handling: signature verified, `alg: none` rejected, expiry (`exp`) checked, audience validated
- OAuth/OIDC: state parameter validated, redirect URI whitelisted, tokens not stored in localStorage

**Authorisation** — check:
- Every endpoint checks authorisation (not just authentication)
- Authorisation checked on the server, not just hidden in the UI
- IDOR: IDs from user input verified against ownership before access
- Privilege escalation: users cannot elevate their own roles
- Default-deny: new resources/endpoints are private by default

Output: findings by category (Authentication / Authorisation) with severity, file:line, description, and remediation.

$ARGUMENTS
