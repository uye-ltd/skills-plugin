---
name: go-update-imports
description: Add, remove, or reorganise import statements in a Go file. Used by Executor Agent after generating or modifying Go code.
language: go
used-by: executor
---

Update the import statements for the specified Go file.

Rules:
1. goimports-compatible grouping: stdlib → external packages → internal packages, separated by blank lines
2. Remove unused imports
3. No dot imports (`. "pkg"`) except in test files where idiomatic
4. Blank `_` imports only for side effects; always add a comment explaining why
5. Import aliases only when package names conflict; avoid unclear abbreviations
6. Prefer the full module path for internal packages
7. Run `goimports` or `gofmt` mentally — produce the same output

Output the complete updated import block plus a summary: added, removed, reorganised.

$ARGUMENTS
