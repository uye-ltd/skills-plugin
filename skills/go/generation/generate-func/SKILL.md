---
name: go-generate-func
description: Generate a Go function from a description or signature. Used by Executor Agent for Go tasks.
language: go
used-by: executor
---

Generate a well-structured Go function for the provided description.

Requirements:
- Return an `error` as the last return value for any fallible operation
- Wrap errors with context: `fmt.Errorf("doing X: %w", err)`
- Accept `context.Context` as the first parameter for any I/O or long-running operation
- Full godoc comment (`// FunctionName does...`)
- Input validation at the boundary; trust internal callers
- No global state; pass dependencies explicitly

Include a usage example in a comment.

$ARGUMENTS
