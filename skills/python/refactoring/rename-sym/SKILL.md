---
name: py-rename-sym
description: Rename a Python symbol (function, class, variable, module) across the codebase. Used by Refactorer Agent for Python tasks.
language: python
used-by: refactorer
---

Rename the specified symbol consistently across the codebase.

Steps:
1. Find the canonical definition
2. Find all references (calls, imports, type annotations, docstrings, tests)
3. Propose the new name with rationale (why is it better?)
4. Apply the rename at definition and all reference sites
5. Update any string references (e.g. in config files, logging messages) if applicable
6. Note if a deprecation alias is needed for backwards compatibility

Show the full list of affected files before applying.

$ARGUMENTS
