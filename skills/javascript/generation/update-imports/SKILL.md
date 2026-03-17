---
name: js-update-imports
description: Add, remove, or reorganise import statements in a JavaScript or TypeScript file. Used by Executor Agent after generating or modifying code.
language: javascript
used-by: executor
---

Update the import statements for the specified file.

Rules:
1. Grouping: external packages → internal aliases → relative imports, blank-line separated
2. Use `import type` for type-only imports (reduces bundle size, clearer intent)
3. No default imports where named imports are available
4. Side-effect-only imports (`import 'reflect-metadata'`) must have a comment explaining why
5. No circular imports — flag as a blocker
6. Avoid namespace imports (`import * as foo`) unless the module has no named exports
- Use named imports over default imports where the module supports it
- Remove unused imports (flag `@ts-ignore` suppressions hiding them)
- Match the existing import style in the file (single quotes vs double, semicolons)

Output the complete updated import block plus a diff summary: added, removed, reorganised.

$ARGUMENTS
