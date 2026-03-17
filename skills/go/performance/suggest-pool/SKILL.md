---
name: go-suggest-pool
description: Identify opportunities to use sync.Pool or connection pooling in Go. Used by Performance Agent for Go tasks.
language: go
used-by: performance
---

Identify where object or connection pooling would reduce GC pressure or connection overhead.

Look for:
- Short-lived objects allocated frequently in hot paths (buffers, byte slices, structs) → `sync.Pool`
- HTTP clients created per-request instead of shared → single `http.Client` with connection pooling
- Database connections opened per-request → connection pool configuration
- `bytes.Buffer` or `strings.Builder` allocated repeatedly → pooled with `sync.Pool`

For each opportunity:
1. Location and what is being allocated
2. Allocation frequency estimate
3. Pool implementation (provide the `sync.Pool` setup code or config change)
4. How to measure improvement: `go test -bench -benchmem` before and after

$ARGUMENTS
