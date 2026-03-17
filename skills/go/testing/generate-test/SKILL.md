---
name: go-generate-test
description: Write Go tests using the standard testing package. Used by Executor Agent for Go tasks.
language: go
used-by: executor,reviewer
---

Write comprehensive Go tests for the provided code.

Guidelines:
- Use the standard `testing` package; add `testify/assert` and `testify/require` if already in the project
- Use table-driven tests for multiple scenarios
- Name subtests descriptively: `t.Run("description", ...)`
- Use interfaces and dependency injection for isolation (not global state patching)
- For HTTP handlers: use `httptest`
- For DB: prefer interface mocks or an in-memory/test DB over patching globals
- Cover: happy paths, error paths, edge cases, boundary values

$ARGUMENTS
