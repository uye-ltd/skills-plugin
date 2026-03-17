---
name: go-remove-dup
description: Remove duplicated code in Go. Used by Refactorer Agent for Go tasks.
language: go
used-by: refactorer
---

Identify and eliminate code duplication.

Rules:
- Before introducing a new abstraction, check if an existing one can be extended
- Prefer the simplest abstraction that removes the duplication
- When extracting to a shared function, preserve error propagation — don't lose error context
- Minimal targeted change — don't restructure surrounding code

Steps:
1. Find duplicate or near-duplicate code blocks
2. Determine the right abstraction (shared function, interface + single implementation, generic function with `comparable`/`any` constraints)
3. Extract the shared logic
4. Replace all duplicate sites
5. Verify error handling is correct at all sites after extraction

For each duplication: location, what varies, proposed abstraction, before/after.

$ARGUMENTS
