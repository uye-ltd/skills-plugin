---
name: js-rename-sym
description: Rename a JavaScript or TypeScript symbol across the codebase. Used by Refactorer Agent for JavaScript tasks.
language: javascript
used-by: refactorer
---

Rename the specified symbol consistently across the codebase.

Steps:
1. Find the canonical definition
2. Find all references (imports, calls, JSX usage, type annotations, tests)
3. Propose the new name with rationale
4. Apply the rename at definition and all reference sites
5. Update any string references (e.g. in event names, CSS class names, test IDs)
6. Note if a deprecation alias is needed

Show the full list of affected files before applying.

$ARGUMENTS
