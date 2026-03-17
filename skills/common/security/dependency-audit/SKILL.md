---
name: dependency-audit
description: Audit project dependencies for known CVEs and security issues. Use when reviewing a dependency manifest or before a release.
language: common
used-by: reviewer,standalone
---

Audit the provided dependency manifest for security issues.

Steps:
1. Identify the package manager from the file (pip/poetry/uv → Python; npm/yarn/pnpm → JS; go mod → Go)
2. Flag dependencies that are pinned to versions with known CVEs (based on known vulnerability patterns)
3. Flag unpinned or wildcard versions (`*`, `>=`, `latest`) that could silently pull in vulnerable versions
4. Flag abandoned packages (no recent releases, archived repos)
5. Suggest the appropriate audit tool to run for a full scan:
   - Python: `pip-audit` or `safety check`
   - JavaScript: `npm audit` or `pnpm audit`
   - Go: `govulncheck ./...`

Output:
- Audit tool command to run for a complete scan
- Flagged packages with version, CVE reference (if known), and recommended version
- Unpinned dependencies list

$ARGUMENTS
