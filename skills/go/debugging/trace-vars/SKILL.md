---
name: go-trace-vars
description: Trace variable state through a Go code path. Used by Debugger Agent for Go tasks.
language: go
used-by: debugger
---

Trace variable state through the specified Go code path.

Steps:
1. Identify variables relevant to the bug (especially pointer vs value semantics)
2. Explicitly trace: inputs → transformation → outputs at each step — track the full execution path, not just the failure point
3. Track pointer vs value semantics at each assignment — identify where a copy is made vs where a reference is passed
4. Flag nil pointer risks, interface boxing/unboxing, slice reslicing, map nil writes
5. Trace error values through the call chain — where is error context lost or not wrapped with `%w`?
6. Note any deferred mutations that affect the result

Output: annotated code path showing each variable's value/type at each step, with the divergence point highlighted.

Suggest `log.Printf` or `dlv` breakpoint placements to confirm in a live environment.

$ARGUMENTS
