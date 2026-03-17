---
name: py-code-review
description: Review Python code for correctness, style, security, and design. Used by Reviewer Agent for Python tasks.
language: python
used-by: reviewer
---

Review the provided Python code across all dimensions:

- **Correctness**: bugs, edge cases, incorrect error handling, off-by-one errors
- **Style**: PEP 8, naming conventions, readability
- **Design**: SOLID principles, appropriate abstractions, unnecessary complexity
- **Performance**: inefficient algorithms, missing caching, unnecessary I/O
- **Security**: injection, insecure defaults, unsafe deserialization, secrets in code
- **Types**: missing annotations, use of `Any`, incorrect generics
- **Testability**: is the code structured to be testable?

Output:
1. Summary (2–3 sentence overall assessment)
2. Issues table (severity: critical / major / minor / nit, file:line, description, suggestion)
3. Verdict: PASS | ITERATE | DEBUG

$ARGUMENTS
