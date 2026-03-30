---
name: js-generate-func
description: Generate a JavaScript or TypeScript function from a description or signature. Used by Executor Agent for JavaScript tasks.
language: javascript
used-by: executor
template: generate-func
---

Generate a well-structured TypeScript function for the provided description.

**Types:** Full TypeScript types on parameters and return value. No `any`. Use `unknown` + type narrowing for truly dynamic values. JSDoc comment with `@param` and `@returns`.

**Async:** `async/await` for any I/O or Promise-based operation. Never fire-and-forget. Always handle rejection.

**Errors:** Throw typed errors for expected failures. Never swallow errors silently. Wrap third-party calls in error boundaries.

**Structure:** `const` over `let`, never `var`. No mutation of parameters.

**Naming:** camelCase for functions and variables.

**Null safety:** Use optional chaining (`?.`) and nullish coalescing (`??`). Avoid falsy `||` where `0` or `""` are valid values.

**Determinism:** No `Math.random()` or `Date.now()` / `new Date()` in testable functions without an injectable source.

$ARGUMENTS
