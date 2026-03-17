---
name: js-remove-dup
description: Remove duplicated code in JavaScript or TypeScript. Used by Refactorer Agent for JavaScript tasks.
language: javascript
used-by: refactorer
---

Identify and eliminate code duplication.

Steps:
1. Find duplicate or near-duplicate code blocks
2. Determine the right abstraction (shared function, custom hook, higher-order component, utility)
3. Extract the shared logic with parameters for the varying parts
4. Replace all duplicate sites
5. Verify TypeScript types remain correct at all call sites

For each duplication: location, what varies, proposed abstraction, before/after.

$ARGUMENTS
