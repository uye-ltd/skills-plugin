---
name: go-check-bugs
description: Check Go code for correctness bugs. Used by Reviewer and Debugger agents for Go tasks.
language: go
used-by: reviewer
---

Perform a correctness-focused scan of the provided Go code.

Check for:
- Ignored error return values
- Nil pointer dereferences (missing nil checks after type assertions, interface returns)
- Incorrect `defer` in loops (all deferred until function return, not loop iteration)
- Integer overflow in arithmetic
- Goroutine leaks (goroutines started but never stopped)
- Incorrect use of `sync.Mutex` (copy of mutex by value, unlock without lock)
- Map access in concurrent code without synchronisation
- Slice/string indexing without bounds checks
- Context not passed or cancelled correctly

For each bug: file:line, description, and minimal fix.

$ARGUMENTS
