---
name: go-suggest-pool
description: Identify opportunities to use sync.Pool or connection pooling in Go. Used by Performance Agent for Go tasks.
language: go
used-by: performance
---

Identify where object or connection pooling would reduce GC pressure or connection overhead.

**Precondition:** Require `go test -bench -benchmem` evidence before recommending pooling — do not suggest `sync.Pool` without allocation data.

Look for:
- Short-lived objects allocated frequently in hot paths (buffers, byte slices, structs) → `sync.Pool`
- HTTP clients created per-request instead of shared → single `http.Client` with connection pooling
- Database connections opened per-request → connection pool configuration
- `bytes.Buffer` or `strings.Builder` allocated repeatedly → pooled with `sync.Pool`

**Note:** `sync.Pool` objects can be collected at any GC cycle — never use for state that must persist across calls.

For each opportunity:
1. Location and what is being allocated
2. Allocation frequency evidence (from benchmarks)
3. Pool implementation (provide the `sync.Pool` setup code or config change)
4. Measure before and after with `b.ReportAllocs()` to confirm reduction

$ARGUMENTS
