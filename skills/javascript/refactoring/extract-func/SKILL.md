---
name: js-extract-func
description: Extract a block of JavaScript or TypeScript code into a named function or hook. Used by Refactorer Agent for JavaScript tasks.
language: javascript
used-by: refactorer
---

Extract the specified code block into a well-named function or custom hook.

Steps:
1. Identify inputs (captured variables) → become parameters
2. Identify outputs (values used after the block) → become return values
3. If the block uses React hooks → extract as a custom `use*` hook
4. Choose a name that describes what the function does
5. Add full TypeScript types and a JSDoc comment
6. Replace the original block with a call to the new function

Show before and after. Note any React rules-of-hooks constraints.

$ARGUMENTS
