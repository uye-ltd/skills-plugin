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

Output:
1. Summary (2–3 sentences)
2. Issues table (severity: critical / major / minor / nit, line, description, suggestion)
3. Verdict: PASS | ITERATE | DEBUG

$ARGUMENTS
