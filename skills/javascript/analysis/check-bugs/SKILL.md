---
name: js-check-bugs
description: Check JavaScript or TypeScript code specifically for bugs and correctness issues. Used by Reviewer and Debugger agents for JavaScript tasks.
language: javascript
used-by: reviewer
---

Perform a correctness-focused scan of the provided JavaScript or TypeScript code.

Check for (with severity):
- Missing `await` on async call (returns Promise instead of value) → **critical**
- Unhandled promise rejection (`.then()` without `.catch()`, unawaited calls) → **critical**
- XSS via unsanitized `innerHTML` or `dangerouslySetInnerHTML` → **critical**
- `==` instead of `===` type coercion → **major**
- Accessing property on potentially-null/undefined value (optional chaining missed) → **major**
- Closure variable capture bug (`var` in loop) → **major**
- Mutating function arguments or props → **major**
- TypeScript `as` cast hiding a real type error → **major**
- React stale closure in `useEffect` → **major**
- Missing dependency in `useEffect`/`useMemo`/`useCallback` array → **major**
- `this` binding issues in callbacks → **major**
- Non-null assertion `!` on value that could genuinely be null → **minor**
- Off-by-one in array indexing → **minor**

For each bug: location, severity, description, and minimal fix.

$ARGUMENTS
