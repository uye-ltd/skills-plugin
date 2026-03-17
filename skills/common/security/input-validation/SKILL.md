---
name: input-validation
description: Review input validation and sanitisation across API boundaries, form handlers, or data ingestion code. Use when auditing untrusted input handling.
language: common
used-by: reviewer,standalone
---

Review the provided code for input validation and sanitisation issues.

Check every point where external data enters the system (HTTP params, request body, file uploads, env vars, CLI args, DB results used in further queries):

- **Missing validation**: no type/format/length checks before use
- **Injection risk**: unsanitised input passed to SQL, shell commands, template engines, or eval
- **Trust boundary violations**: data from one trust level used at a higher trust level without re-validation
- **Incorrect validation order**: sanitise before validate (should be validate then sanitise)
- **Allowlist vs denylist**: denylist-based validation (easy to bypass) instead of allowlist
- **Error messages**: validation errors leaking internal schema, stack traces, or system info
- **Mass assignment**: accepting all fields from a request and binding to a model without filtering

Output: list of validation gaps by severity with file:line, the input source, what is missing, and the correct validation pattern for the language in use.

$ARGUMENTS
