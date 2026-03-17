---
name: py-trace-vars
description: Trace the state of variables through a Python code path. Used by Debugger Agent to understand what values exist at the point of failure.
language: python
used-by: debugger
---

Trace variable state through the specified code path.

Steps:
1. Identify the variables relevant to the bug or failure
2. Walk through the code path step-by-step, tracking how each variable's value changes
3. Identify where a variable's value diverges from what the code expects
4. Note any implicit type coercions, None propagation, or mutation side effects

Output: annotated code path showing the value of each tracked variable at each step, highlighting the divergence point.

Suggest where to add logging or assertions to confirm the trace in a live environment.

$ARGUMENTS
