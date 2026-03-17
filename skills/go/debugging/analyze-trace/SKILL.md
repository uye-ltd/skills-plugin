---
name: go-analyze-trace
description: Analyse a Go stack trace or panic output. Used by Debugger Agent for Go tasks.
language: go
used-by: debugger
---

Parse and explain the provided Go panic or error stack trace.

Rules:
- Do **not** emit a "Fix" section until the Root Cause section is complete
- After walking the goroutine stack, trace the full execution path: inputs → transformation → outputs — confirm where state diverges from expected
- For panics: identify whether the cause is a programmer error (invariant violation) or expected-error mishandling (should have returned error instead)

Steps:
1. Identify the panic type or error and its message
2. Walk the goroutine stack from origin to failure
3. Identify the exact line of failure and why it failed
4. Note if multiple goroutines are involved (deadlock, race condition)
5. Distinguish root cause from propagation

Output:
- **Failure**: type and message
- **Root cause location**: file:line
- **Goroutine context**: which goroutine(s) are involved
- **Root cause explanation**: why it happened (programmer invariant violation vs expected-error mishandling)
- **Suggested next step**: fix, or `go-trace-vars` / `go-check-goroutine`

$ARGUMENTS
