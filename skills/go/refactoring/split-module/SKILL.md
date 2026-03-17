---
name: go-split-module
description: Split a large Go file or package into smaller, focused packages. Used by Refactorer Agent for Go tasks.
language: go
used-by: refactorer
---

Split the specified Go file or package.

Steps:
1. Identify logical groupings (by domain, responsibility, or layer)
2. Propose new package names following Go naming conventions (short, lowercase, no underscores)
3. Move types and functions to their new packages
4. Resolve import cycles (they are illegal in Go — flag any)
5. Update all call sites across the module
6. Keep exported API stable; add a deprecation note in the old location if needed

Output: proposed split plan for approval before making changes.

$ARGUMENTS
