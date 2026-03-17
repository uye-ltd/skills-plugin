---
name: go-analyze-trace
description: Analyse a Go stack trace or panic output. Used by Debugger Agent for Go tasks.
language: go
used-by: debugger
---

Parse and explain the provided Go panic or error stack trace.

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
- **Root cause explanation**: why it happened
- **Suggested next step**: fix, or `go-trace-vars` / `go-check-goroutine`

$ARGUMENTS
