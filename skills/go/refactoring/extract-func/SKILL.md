---
name: go-extract-func
description: Extract a block of Go code into a named function. Used by Refactorer Agent for Go tasks.
language: go
used-by: refactorer
---

Extract the specified code block into a well-named Go function.

Steps:
1. Identify inputs (variables from outer scope) → parameters
2. Identify outputs (variables used after block) → return values (include `error` if fallible)
3. Choose a name that describes what the function does
4. Add a godoc comment
5. Accept `context.Context` if the extracted code does I/O
6. Replace the original block with a call to the new function

Show before and after. Note any deferred calls or named return values that complicate the extraction.

$ARGUMENTS
