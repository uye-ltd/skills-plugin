---
name: py-trace-vars
description: Trace the state of variables through a Python code path. Used by Debugger Agent to understand what values exist at the point of failure.
language: python
used-by: debugger
template: trace-vars
Trace variable state through the specified code path.

Steps:
1. Identify the variables relevant to the bug or failure
2. Explicitly trace: inputs → transformation → outputs at each step — track the full execution path, not just the failure point
3. Walk through the code path step-by-step, tracking how each variable's value changes
4. Check for mutation of input arguments as a source of unexpected state changes
5. Identify where a variable's value diverges from what the code expects
6. Note any implicit type coercions, None propagation, or mutation side effects

Output: annotated code path showing the value of each tracked variable at each step, highlighting the divergence point.

Suggest where to add logging or assertions to confirm the trace in a live environment.

$ARGUMENTS
