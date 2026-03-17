---
name: js-generate-func
description: Generate a JavaScript or TypeScript function from a description or signature. Used by Executor Agent for JavaScript tasks.
language: javascript
used-by: executor
---

Generate a well-structured TypeScript function for the provided description.

**Approach:** Prefer idiomatic TypeScript. Simplest correct solution. Think about error paths, null safety, and testability first.

Requirements:
- Full TypeScript types on parameters and return value
- JSDoc comment with `@param` and `@returns`
- `async/await` if the function performs I/O
- Explicit error handling (typed errors where appropriate)
- No implicit `any`
- Pure function design where possible (no hidden state)

**Async:** Use `async/await` for any I/O or Promise-based operation. Never fire-and-forget. Always handle rejection.

**Types:** Full TypeScript types on parameters and return value. No `any`. Use `unknown` + type narrowing for truly dynamic values.

**Errors:** Throw typed errors for expected failures. Never swallow errors silently. Wrap third-party calls in error boundaries.

**Structure:** Functions ≤ ~30 lines, single concern. `const` over `let`, never `var`. No mutation of parameters. Business logic independent from I/O.

**Naming:** camelCase for functions and variables. Descriptive verb-first names (`processOrder`, `validateInput`). No vague or abbreviated names.

**Null safety:** Use optional chaining (`?.`) and nullish coalescing (`??`). Avoid falsy `||` where `0` or `""` are valid values.

**Security:** Validate all external inputs at function boundaries. No hardcoded credentials or config.

**Determinism:** No `Math.random()` or `Date.now()` / `new Date()` in testable functions without an injectable source.

Include a usage example.

$ARGUMENTS
