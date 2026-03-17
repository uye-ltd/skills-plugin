---
name: go-rename-sym
description: Rename a Go symbol (function, type, variable, package) across the codebase. Used by Refactorer Agent for Go tasks.
language: go
used-by: refactorer
---

Rename the specified symbol consistently across the codebase.

Steps:
1. Find the canonical definition
2. Find all references (calls, type usages, interface implementations, tests)
3. Propose the new name — must follow Go naming conventions (exported = UpperCamel, unexported = lowerCamel)
4. Apply the rename
5. Update godoc comments that reference the old name
6. Note if a type alias is needed for backwards compatibility

Show the full list of affected files before applying.

$ARGUMENTS
