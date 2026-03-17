---
name: js-add-types
description: Add or improve TypeScript types in JavaScript or TypeScript code. Used by Refactorer Agent for JavaScript tasks.
language: javascript
used-by: refactorer
---

Add comprehensive TypeScript annotations to the provided code.

Guidelines:
- Eliminate all `any` — use `unknown` for truly dynamic values, then narrow
- Use `interface` for object shapes that will be extended; `type` for unions, intersections, aliases
- Use discriminated unions for variant types
- Add generics where a function works the same way for multiple types
- Use `as const` for literal objects/arrays
- Use `readonly` on arrays and object properties that should not be mutated
- Add `ReturnType<>` / `Parameters<>` for derived types rather than duplicating
- Use `satisfies` operator for objects where you want type-checking but want to preserve literal types
- No `!` non-null assertion without justification — use optional chaining or explicit null checks

Note any places where the JS code structure makes typing difficult and suggest refactoring.

$ARGUMENTS
