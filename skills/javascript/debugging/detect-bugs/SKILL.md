---
name: js-detect-bugs
description: Scan JavaScript or TypeScript code for bugs. Used by Debugger Agent for proactive bug detection in JavaScript tasks.
language: javascript
used-by: debugger
---

Perform a bug-focused scan of the provided JS/TS code.

Look for:
- `==` type coercion bugs
- Missing `await` on async calls
- Unhandled promise rejections
- `undefined`/`null` access without guards
- Closure variable capture bugs (especially `var` in loops)
- Mutated props or function arguments
- React: stale closures, missing dependency arrays, effects running too often
- TypeScript: `as` casts that could fail at runtime, non-null assertions (`!`) that are unsafe

For each bug: file:line, description, and minimal fix.

$ARGUMENTS
