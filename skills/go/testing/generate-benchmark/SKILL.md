---
name: go-generate-benchmark
description: Write Go benchmark functions for performance-sensitive code. Used by Executor and Performance agents for Go tasks.
language: go
used-by: executor,reviewer
---

Write Go benchmark functions for the provided code.

Requirements:
- Follow `BenchmarkXxx(b *testing.B)` convention
- Reset the timer after setup: `b.ResetTimer()`
- Use `b.ReportAllocs()` to track allocations
- For parallel benchmarks use `b.RunParallel`
- Avoid compiler optimisations: assign results to a package-level variable
- Cover both small and large input sizes to reveal O(n) behaviour

Include the `go test -bench` command to run the benchmarks and what to look for in the output.

$ARGUMENTS
