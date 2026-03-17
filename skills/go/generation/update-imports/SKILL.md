---
name: go-update-imports
description: Add, remove, or reorganise import statements in a Go file. Used by Executor Agent after generating or modifying Go code.
language: go
used-by: executor
---

Update the import statements for the specified Go file.

Rules (goimports-compatible):
- Group: stdlib → external packages → internal packages, separated by blank lines
- Remove unused imports
- Use import aliases only when package names conflict
- Prefer the full module path for internal packages
- Run `goimports` or `gofmt` mentally — produce the same output

Output the complete updated import block plus a summary: added, removed, reorganised.

$ARGUMENTS
