---
name: js-check-async
description: Check JavaScript or TypeScript async/Promise code for correctness. Used by Debugger Agent for JS async bugs.
language: javascript
used-by: debugger
---

Review the provided async JS/TS code for concurrency and correctness issues.

Check for:
- Missing `await` (returning `Promise` where a value is expected)
- Fire-and-forget `async` calls that should be awaited
- `Promise.all` vs `Promise.allSettled` — is failure handling correct?
- Unhandled rejection in `.then()` chains (missing `.catch()`)
- Race conditions: two async operations that can interleave incorrectly
- Sequential `await` inside a loop where `Promise.all` would be faster
- React: async state updates after component unmount
- Error swallowing in `try/catch` blocks that only log

For each issue: location, problem, and correct async pattern.

$ARGUMENTS
