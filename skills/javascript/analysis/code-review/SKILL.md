---
name: js-code-review
description: Review JavaScript or TypeScript code for correctness, type safety, and best practices. Used by Reviewer Agent for JavaScript tasks.
language: javascript
used-by: reviewer
---

Review the provided JavaScript or TypeScript code:

- **Correctness**: logic bugs, incorrect async/await, unhandled promise rejections
- **TypeScript**: unsafe `any`, missing types, incorrect generics, type assertions hiding bugs
- **Style**: naming conventions, unnecessary verbosity, ESLint compliance
- **Design**: component/function decomposition, separation of concerns
- **Performance**: unnecessary re-renders, missing memoisation, large bundle impact
- **Security**: XSS risks, unsafe `innerHTML`, unvalidated inputs, exposed secrets
- **Error handling**: swallowed errors, missing try/catch, unhandled rejection handlers

## JavaScript standards checklist

**Async & Promises:**
- [ ] All async calls awaited or explicitly fire-and-forget
- [ ] All Promises have rejection handlers
- [ ] `Promise.all` used for independent parallel operations (not sequential `await` in loop)
- [ ] Error propagation traced through async call chain

**TypeScript:**
- [ ] No `any` types (use `unknown` + narrowing)
- [ ] No `as` casts masking real type errors
- [ ] No `!` non-null assertions without justification
- [ ] Return types annotated on all exported functions
- [ ] Generics used over `any` for polymorphic functions

**Null/undefined safety:**
- [ ] Optional chaining used where values may be absent
- [ ] Nullish coalescing (`??`) used over falsy `||` where `0` / `""` are valid
- [ ] No unguarded property access after API calls or parsing

**Error handling:**
- [ ] No silent catch blocks
- [ ] Errors rethrown with context or explicitly handled
- [ ] Typed errors for domain-level failures

**Structure:**
- [ ] Functions ≤ ~30 lines; single concern
- [ ] No `var`; prefer `const` over `let`
- [ ] No mutation of parameters
- [ ] Business logic decoupled from UI/I/O

**Naming:**
- [ ] camelCase for variables/functions; PascalCase for classes/types/components
- [ ] Boolean names: `is/has/should` prefix
- [ ] No vague or abbreviated names

**Imports:**
- [ ] Grouping: external → internal → relative
- [ ] `import type` for type-only imports
- [ ] No unused imports; no circular imports

**Security:**
- [ ] No `innerHTML` / `dangerouslySetInnerHTML` with unsanitized content
- [ ] External inputs validated at module boundaries
- [ ] No hardcoded credentials or API keys

**React (when applicable):**
- [ ] `key` prop is stable (not array index for dynamic lists)
- [ ] No stale closures in `useEffect`
- [ ] Dependency arrays complete
- [ ] No async functions directly assigned as `useEffect` callback

Output:
1. Summary (2–3 sentences)
2. Issues table (severity: critical / major / minor / nit, line, description, suggestion)
3. Verdict: PASS | ITERATE | DEBUG

$ARGUMENTS
