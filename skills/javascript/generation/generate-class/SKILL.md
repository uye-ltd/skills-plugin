---
name: js-generate-class
description: Generate a TypeScript class from a description or spec. Used by Executor Agent for JavaScript tasks.
language: javascript
used-by: executor
---

Generate a well-structured TypeScript class for the provided description.

Requirements:
- Access modifiers on all members (`private`, `protected`, `public`)
- Type annotations on all properties and methods
- Constructor with dependency injection (no `new` inside constructor for external deps)
- JSDoc on class and public methods
- Immutability by default (use `readonly` where appropriate)
- Prefer composition over inheritance unless inheritance is clearly appropriate

Include a minimal usage example.

$ARGUMENTS
