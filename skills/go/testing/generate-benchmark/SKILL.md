---
name: go-generate-benchmark
description: Write Go benchmark functions for performance-sensitive code. Used by Executor and Performance agents for Go tasks.
language: go
used-by: executor,reviewer
---

Write Go benchmark functions for the provided code.

**Precondition:** Only suggest a benchmark if profiling (`pprof`, `go test -bench`) has indicated this path is a hotspot. Do not create benchmarks speculatively.

Requirements:
- Follow `BenchmarkXxx(b *testing.B)` convention
- Reset the timer after setup: `b.ResetTimer()`
- Always include `b.ReportAllocs()` to track allocation count
- Assign benchmark result to a package-level `var Sink` to prevent compiler optimisation of the measured code
- For parallel benchmarks use `b.RunParallel`
- Cover both small and large input sizes to reveal O(n) scaling

Include the `go test -bench` command to run the benchmarks and what to look for in the output.

$ARGUMENTS
