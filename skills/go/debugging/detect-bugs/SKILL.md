---
name: go-detect-bugs
description: Scan Go code for bugs. Used by Debugger Agent for proactive bug detection in Go tasks.
language: go
used-by: debugger
---

Perform a bug-focused scan of the provided Go code.

Look for:
- Ignored error return values (`_, err` or no error check)
- Nil pointer dereferences without nil checks
- `defer` inside a loop (deferred until function end, not loop iteration)
- Goroutine leaks (started goroutines with no exit path)
- Map writes on nil map
- Slice append returning a new slice that is discarded
- Integer overflow
- Incorrect mutex usage (copy by value, unlock of unlocked mutex)
- Missing context cancellation propagation
- Error wrapping gaps: errors passed through without `%w`, losing the chain for `errors.Is`/`errors.As`
- Goroutines without exit paths or context cancellation checks
- `sync.Mutex`/`sync.WaitGroup` copied by value
- Race-prone patterns: concurrent map/slice writes without synchronisation
- Type assertion without ok check: `v := x.(T)` panics on wrong type
- Hardcoded config values or credentials that could cause production bugs

For each bug: file:line, description, severity, and minimal fix.

$ARGUMENTS
