---
name: js-analyze-trace
description: Analyse a JavaScript or TypeScript stack trace or error. Used by Debugger Agent for JavaScript tasks.
language: javascript
used-by: debugger
---

Parse and explain the provided JS/TS error and stack trace.

**Rules:**
- Do **not** emit a "Fix" section until the Root Cause section is complete
- After walking the stack, trace the full execution path: inputs → transformation → outputs — confirm where state diverges from expected
- For async errors: trace the Promise chain from initiation to failure — identify at which `.then()`/`await` the error was swallowed or re-thrown

Steps:
1. Identify the error type and message
2. Walk the stack from origin to failure point
3. Identify the exact line of failure and why it failed
4. Distinguish between root cause and propagation
5. Note any async boundary crossings in the stack (Promise chains, async/await transitions)

Output:
- **Error**: type and message
- **Root cause location**: file:line
- **Async context**: if this is an async error, describe the promise chain
- **Root cause explanation**: why it happened
- **Suggested next step**: fix, or which debugging skill to run next

$ARGUMENTS
