---
name: secrets-scan
description: Scan code for hardcoded secrets, credentials, tokens, or API keys. Use before committing or during code review when security is a concern.
language: common
used-by: reviewer,standalone
---

Scan the provided code for hardcoded sensitive values.

Look for:
- API keys, tokens, and secrets (recognisable by common patterns: `sk-`, `ghp_`, `AKIA`, UUIDs in string assignments)
- Passwords and passphrases assigned to variables
- Private keys or certificate content inline in code
- Database connection strings with embedded credentials
- Hardcoded internal hostnames, IPs, or environment-specific URLs
- Base64-encoded blobs that may contain credentials

For each finding:
- **Location**: file:line
- **Type**: what kind of secret it appears to be
- **Severity**: critical (real secret) / warning (looks like a secret but may be a placeholder)
- **Fix**: the correct approach (env var, secret manager, config file outside version control)

Also flag: `.env` files that are not in `.gitignore`, config files with plaintext credentials.

$ARGUMENTS
