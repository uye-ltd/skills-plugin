---
name: js-generate-func
description: Generate a JavaScript or TypeScript function from a description or signature. Used by Executor Agent for JavaScript tasks.
language: javascript
used-by: executor
---

Generate a well-structured TypeScript function for the provided description.

Requirements:
- Full TypeScript types on parameters and return value
- JSDoc comment with `@param` and `@returns`
- `async/await` if the function performs I/O
- Explicit error handling (typed errors where appropriate)
- No implicit `any`
- Pure function design where possible (no hidden state)

Include a usage example.

$ARGUMENTS
