---
name: go-check-goroutine
description: Check Go code for goroutine and concurrency bugs. Used by Debugger Agent for Go concurrency issues.
language: go
used-by: debugger
---

Review the provided Go code for concurrency and goroutine correctness issues.

Check for:
- Goroutine leaks: goroutines with no exit condition or blocked forever
- Data races: shared variables accessed from multiple goroutines without synchronisation
- Deadlock patterns: two goroutines waiting for each other
- Channel direction not enforced in function signatures
- `sync.WaitGroup` misuse (Add called after Wait, Done in wrong goroutine)
- `sync.Mutex` copied by value
- Context cancellation not checked inside goroutine loops
- `select` with no `default` that could block indefinitely

For each issue: location, problem, and correct concurrent pattern.

Always suggest running with `-race` flag to confirm data races.

$ARGUMENTS
