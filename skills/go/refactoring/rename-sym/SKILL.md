---
name: go-rename-sym
description: Rename a Go symbol (function, type, variable, package) across the codebase. Used by Refactorer Agent for Go tasks.
language: go
used-by: refactorer
---

Rename the specified symbol consistently across the codebase.

Pre-rename checklist (verify the proposed name satisfies all rules):
- Exported symbols: UpperCamelCase (`ProcessOrder`, `UserStore`)
- Unexported symbols: lowerCamelCase (`processOrder`, `userStore`)
- Package names: short, lowercase, no underscores
- Interface names: behaviour-based with `-er` suffix where appropriate
- No stutter: package name must not repeat in the exported symbol name
- Acronyms: consistent — all-caps or all-lowercase (`HTTPClient` or `httpClient`, never `HttpClient`)
- Receiver names: 1–2 letter abbreviation of the type, consistent within the type, never `self` or `this`
- No vague or abbreviated names (`data`, `tmp`, `mgr`, `proc`)

Steps:
1. Find the canonical definition
2. Find all references (calls, type usages, interface implementations, tests)
3. Propose the new name — verify it passes the checklist above
4. Apply the rename
5. Update godoc comments that reference the old name
6. Note if a type alias is needed for backwards compatibility

Show the full list of affected files before applying.

$ARGUMENTS
