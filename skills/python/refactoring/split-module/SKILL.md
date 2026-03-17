---
name: py-split-module
description: Split a large Python module into smaller, focused modules. Used by Refactorer Agent for Python tasks.
language: python
used-by: refactorer
---

Split the specified Python module into smaller, cohesive modules.

**Trigger conditions:** class > ~100 lines, module mixing unrelated responsibilities.

Steps:
1. Identify logical groupings of functions/classes (by domain, responsibility, or layer)
2. Propose the new module names and what each will contain — each resulting module must implement one clear responsibility
3. Move symbols to their new modules
4. Update all import statements across the codebase:
   - `__init__.py` re-exports use relative imports from the same package
   - All other imports use absolute imports
5. New modules use absolute imports throughout
6. Add a re-export from the original module if backwards compatibility is needed (add a deprecation notice)

Output: proposed split plan for approval before making changes. After approval, produce the updated files.

$ARGUMENTS
