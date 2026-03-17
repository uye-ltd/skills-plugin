---
name: js-trace-vars
description: Trace variable state through a JavaScript or TypeScript code path. Used by Debugger Agent to understand values at the point of failure.
language: javascript
used-by: debugger
---

Trace variable state through the specified code path.

Steps:
1. Identify variables relevant to the bug
2. Walk through the code path, tracking value changes
3. Flag implicit type coercions (`==`, `+` string/number, falsy checks)
4. Track `undefined` / `null` propagation through optional chaining and nullish coalescing
5. Note any async state changes (values that change after `await`)

Output: annotated code path showing each variable's value at each step, highlighting the divergence point.

Suggest `console.log` or `debugger` breakpoint placements to confirm in a live environment.

$ARGUMENTS
