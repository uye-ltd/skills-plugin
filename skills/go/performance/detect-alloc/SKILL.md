---
name: go-detect-alloc
description: Identify unnecessary heap allocations in Go code. Used by Performance Agent for Go tasks.
language: go
used-by: performance
---

Identify sources of unnecessary heap allocations in the provided Go code.

Look for:
- Interface boxing: values assigned to `interface{}` / `any` causing heap escape
- Closures capturing loop variables (each iteration may allocate)
- Slice/map growth: pre-allocate with `make([]T, 0, n)` where n is known
- String concatenation in a loop → use `strings.Builder`
- Returning pointers to stack values unnecessarily (forces heap allocation)
- Small structs passed by pointer instead of value when value would stay on stack

For each allocation:
1. Location and cause
2. Expected allocation per call
3. Fix and expected allocation reduction
4. Verification: `go test -bench -benchmem` and `go build -gcflags="-m"` to see escape analysis

$ARGUMENTS
