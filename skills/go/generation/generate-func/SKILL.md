---
name: go-generate-func
description: Generate a Go function from a description or signature. Used by Executor Agent for Go tasks.
language: go
used-by: executor
---

Generate a well-structured Go function for the provided description.

**Approach:** Prefer idiomatic Go. Simplest correct solution. Think about error paths and testability first.

**Context:** Accept `context.Context` as the first parameter for any I/O or long-running operation. Pass it through — never store it.

**Errors:** Return `error` as the last return value for any fallible operation. Wrap with context: `fmt.Errorf("doing X: %w", err)`. Never ignore errors. Use sentinel errors for matchable conditions; custom error types for structured domain errors.

**Structure:** Functions ≤ ~30 lines, single concern. No global state; pass all dependencies as parameters. Business logic independent from I/O. No panic for expected errors.

**Naming:** Verb-first names for functions (`ProcessOrder`, `validateInput`). Exported = UpperCamelCase, unexported = lowerCamelCase. No vague or abbreviated names.

**Docs:** Godoc comment starting with the function name (`// FunctionName does...`).

**defer & Resources:** Defer cleanup immediately after acquisition. Never defer inside a loop.

**Concurrency:** Never start a goroutine without a defined exit path. Always accept and check context cancellation.

**Security:** Validate all external inputs at the function boundary. No hardcoded credentials or config.

**Determinism:** No unseeded `rand` unless explicitly required.

Include a usage example in a comment.

$ARGUMENTS
