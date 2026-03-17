---
name: go-generate-test
description: Write Go tests using the standard testing package. Used by Executor Agent for Go tasks.
language: go
used-by: executor,reviewer
---

Write comprehensive Go tests for the provided code.

Guidelines:
- Use the standard `testing` package; add `testify/assert` and `testify/require` if already in the project
- Table-driven tests using `t.Run("scenario_description", ...)` subtests
- Subtest names describe scenario and expected outcome (not "case 1", "test A", "scenario 2")
- Tests must be deterministic: no `time.Sleep` for synchronisation, no unseeded `rand`, no implicit external state
- Use interfaces and DI for isolation — not global variable patching
- `t.Fatal` when continuing the test is meaningless after a failure; `t.Error` for non-blocking failures
- Inline comments explain *why* an edge case is tested, not *what* the test does
- Add `-race` flag comment for any test covering concurrent code
- For HTTP handlers: use `httptest`
- For DB: prefer interface mocks or an in-memory/test DB over patching globals
- Cover: happy paths, error paths, edge cases, boundary values

$ARGUMENTS
