---
name: py-update-imports
description: Add, remove, or reorganise Python import statements. Used by Executor Agent after generating or modifying code.
language: python
used-by: executor
---

Update the import statements for the specified file.

Rules:
- Group imports: stdlib → third-party → local (PEP 8), separated by blank lines
- Use `isort`-compatible ordering within each group
- Remove unused imports
- Use explicit imports over wildcard (`from x import *`)
- Prefer absolute imports over relative for top-level packages
- Add `from __future__ import annotations` if needed for forward references

Output the complete updated import block, then list: added, removed, reorganised.

$ARGUMENTS
