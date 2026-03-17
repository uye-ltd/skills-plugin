---
name: py-rename-sym
description: Rename a Python symbol (function, class, variable, module) across the codebase. Used by Refactorer Agent for Python tasks.
language: python
used-by: refactorer
---

Rename the specified symbol consistently across the codebase.

**Pre-rename checklist — the new name must satisfy all of these:**
- Functions/methods: starts with a verb (`process_order`, `validate_input`, `build_query`)
- Classes: PascalCase noun (`Order`, `InputValidator`, `QueryBuilder`)
- Variables/attributes: snake_case noun or noun phrase
- Module-level constants: UPPER_CASE (`MAX_RETRIES`, `DEFAULT_TIMEOUT`)
- No single-letter names except `i`, `j` in loops
- No vague, generic, or abbreviated names (`data`, `tmp`, `proc`, `mgr`)
- Reflects purpose and intent, not implementation details

Steps:
1. Find the canonical definition
2. Verify the proposed new name passes the checklist above
3. Find all references (calls, imports, type annotations, docstrings, tests)
4. Apply the rename at definition and all reference sites
5. Update any string references (e.g. in config files, logging messages) if applicable
6. Note if a deprecation alias is needed for backwards compatibility

Show the full list of affected files before applying.

$ARGUMENTS
