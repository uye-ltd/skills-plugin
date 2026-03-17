---
name: docs-review
description: Review existing documentation for accuracy, clarity, completeness, and consistency.
language: common
used-by: standalone
---

Review the provided documentation and produce a structured critique followed by an improved version.

Check for:
- Technical accuracy (does it match the actual code behaviour?)
- Clarity (is it understandable to the intended audience?)
- Completeness (missing parameters, edge cases, error states, examples?)
- Consistency (terminology, formatting, style vs the rest of the project)
- Staleness (outdated references, removed features)

Output:
1. Issues found (grouped by severity: critical / minor / suggestion)
2. Revised documentation

$ARGUMENTS
