---
name: py-analyze-trace
description: Analyse a Python stack trace to identify the failure point. Used by Debugger Agent for Python tasks.
language: python
used-by: debugger
---

Parse and explain the provided Python stack trace.

Steps:
1. Identify the exception type and message
2. Walk the stack from bottom (origin) to top (failure point)
3. Trace the full execution path: inputs → transformation → outputs — confirm where state diverges from expected
4. Identify the exact line of failure and why it failed
5. Distinguish between the root cause and the propagation chain
6. Identify any relevant context (what was the code trying to do?)

Output rules:
- Do **not** emit a "Fix" or "Recommended action" section until the Root Cause section is complete
- The Root Cause explanation must describe *why* the failure happens, not just *where*

Output:
- **Exception**: type and message
- **Root cause location**: file:line — what triggered this
- **Propagation chain**: how it bubbled up
- **Root cause explanation**: why it happened (full, not just the symptom)
- **Suggested next step**: fix, or which `trace-vars` / `detect-bugs` skill to run next

$ARGUMENTS
