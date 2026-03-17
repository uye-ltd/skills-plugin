---
name: go-check-bugs
description: Check Go code for correctness bugs. Used by Reviewer and Debugger agents for Go tasks.
language: go
used-by: reviewer
---

Perform a correctness-focused scan of the provided Go code.

Check for:
- Ignored error return values (blank `_` or no check at all) → **critical**
- `defer` inside a loop (defers until function return, not iteration end) → bug
- Goroutine leak: goroutine with no exit path or no context cancellation check → **critical**
- Data race: shared map/slice/struct written from multiple goroutines without sync → **critical**
- Nil map write (writing to an uninitialized `map`) → runtime panic
- Slice `append` result discarded: `append(s, x)` without assignment back to `s`
- `sync.Mutex` or `sync.WaitGroup` copied by value (passed by value to function or assigned)
- Type assertion without ok check: `v := x.(T)` panics if wrong type; use `v, ok := x.(T)`
- Context not propagated through call chain (hardcoded `context.Background()` mid-stack)
- Error context lost: error passed through without `%w`, losing the chain
- Nil pointer dereferences (missing nil checks after type assertions, interface returns)
- Integer overflow in arithmetic
- Slice/string indexing without bounds checks

For each bug: file:line, description, severity, and minimal fix.

$ARGUMENTS
