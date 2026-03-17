---
name: js-check-bugs
description: Check JavaScript or TypeScript code specifically for bugs and correctness issues. Used by Reviewer and Debugger agents for JavaScript tasks.
language: javascript
used-by: reviewer
---

Perform a correctness-focused scan of the provided JavaScript or TypeScript code.

Check for:
- `==` instead of `===` causing type coercion bugs
- `undefined` / `null` not guarded (optional chaining missed)
- `async` functions missing `await` (returning Promise instead of value)
- Unhandled promise rejections (`.then()` without `.catch()`, unawaited calls)
- Mutating function arguments or props
- Closure variable capture bugs in loops (`var` inside `for`)
- `this` binding issues in callbacks
- TypeScript `as` casts that bypass the type system
- Off-by-one in array indexing

For each bug: location, description, and minimal fix.

$ARGUMENTS
