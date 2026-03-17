---
name: js-check-async
description: Check JavaScript or TypeScript async/Promise code for correctness. Used by Debugger Agent for JS async bugs.
language: javascript
used-by: debugger
---

Review the provided async JS/TS code for concurrency and correctness issues.

**Rule:** Do **not** suggest fixing async patterns until the failure point is identified.

Check for:
- Missing `await` (returning `Promise` where a value is expected)
- Fire-and-forget `async` calls that should be awaited
- `Promise.all` vs `Promise.allSettled` — is failure handling correct?
- Unhandled rejection in `.then()` chains (missing `.catch()`)
- Race conditions: two async operations that can interleave incorrectly
- Sequential `await` inside a loop where `Promise.all` would be faster
- React: async state updates after component unmount
- Error swallowing in `try/catch` blocks that only log
- Missing `AbortController` / cancellation on async operations that outlive their originating context (e.g. component unmount, request cancellation)
- Node.js `EventEmitter`: listener added in setup but never removed — memory leak

For each issue: location, problem, and correct async pattern.

$ARGUMENTS
