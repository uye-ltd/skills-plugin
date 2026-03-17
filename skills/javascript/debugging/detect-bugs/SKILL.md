---
name: js-detect-bugs
description: Scan JavaScript or TypeScript code for bugs. Used by Debugger Agent for proactive bug detection in JavaScript tasks.
language: javascript
used-by: debugger
template: detect-bugs
Perform a bug-focused scan of the provided JS/TS code.

Look for (with severity):
- Missing `await` on async calls → **critical**
- Unhandled promise rejections → **critical**
- `==` type coercion bugs → **major**
- `undefined`/`null` access without guards → **major**
- Closure variable capture bugs (especially `var` in loops) → **major**
- Mutated props or function arguments → **major**
- React: stale closures, missing dependency arrays, effects running too often → **major**
- TypeScript: `as` casts that could fail at runtime → **major**
- Non-null assertions (`!`) that are unsafe → **minor**

For each bug: file:line, severity, description, and minimal fix.

$ARGUMENTS
