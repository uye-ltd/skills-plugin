---
name: js-generate-component
description: Generate a React, Vue, or Svelte component from a description or design spec. Used by Executor Agent for JavaScript tasks.
language: javascript
used-by: executor
---

Build a production-ready UI component for the provided description.

Guidelines:
- Detect framework from project context; default to React with TypeScript
- Full prop types / interfaces
- Handle loading, error, and empty states
- Semantic HTML with ARIA attributes and keyboard navigation
- Match project styling convention (Tailwind, CSS modules, styled-components — check project)
- Decompose into sub-components if complex
- Add JSDoc on the component and non-obvious props

**Component standards:**
- Component names: PascalCase; props interface named `<ComponentName>Props`
- No business logic in components — delegate to custom hooks or services
- `key` prop must be stable (not array index unless list is static and never reordered)
- Never mutate props
- Avoid inline object/array creation in JSX (new reference every render)
- No direct DOM manipulation; use React refs only when necessary

Include a usage example.

$ARGUMENTS
