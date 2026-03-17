---
name: go-trace-vars
description: Trace variable state through a Go code path. Used by Debugger Agent for Go tasks.
language: go
used-by: debugger
---

Trace variable state through the specified Go code path.

Steps:
1. Identify variables relevant to the bug (especially pointer vs value semantics)
2. Walk through the code path tracking value and type changes
3. Flag nil pointer risks, interface boxing/unboxing, slice reslicing, map nil writes
4. Track error values through the call chain — where is error context lost?
5. Note any deferred mutations that affect the result

Output: annotated code path showing each variable's value/type at each step, with the divergence point highlighted.

Suggest `log.Printf` or `dlv` breakpoint placements to confirm in a live environment.

$ARGUMENTS
