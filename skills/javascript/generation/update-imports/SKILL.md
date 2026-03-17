---
name: js-update-imports
description: Add, remove, or reorganise import statements in a JavaScript or TypeScript file. Used by Executor Agent after generating or modifying code.
language: javascript
used-by: executor
---

Update the import statements for the specified file.

Rules:
- Group: external packages → internal aliases → relative imports, separated by blank lines
- Use named imports over default imports where the module supports it
- Remove unused imports (flag `@ts-ignore` suppressions hiding them)
- Prefer `import type` for type-only imports (reduces bundle size, clearer intent)
- Match the existing import style in the file (single quotes vs double, semicolons)

Output the complete updated import block plus a diff summary: added, removed, reorganised.

$ARGUMENTS
