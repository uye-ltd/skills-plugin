---
name: go-split-module
description: Split a large Go file or package into smaller, focused packages. Used by Refactorer Agent for Go tasks.
language: go
used-by: refactorer
---

Split the specified Go file or package.

**Trigger conditions:** package mixes unrelated responsibilities, or an import cycle is detected (illegal in Go).

Steps:
1. Identify logical groupings (by domain, responsibility, or layer)
2. Each resulting package implements one clear responsibility
3. Propose new package names: short, lowercase, no underscores
4. Resolve import cycles — flag any cycle as a blocker before proceeding
5. Move types and functions to their new packages
6. Update all cross-package references; keep exported API stable
7. Add a deprecation note in the old location if needed

Output: proposed split plan for approval before making changes.

$ARGUMENTS
