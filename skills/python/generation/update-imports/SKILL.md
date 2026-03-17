---
name: py-update-imports
description: Add, remove, or reorganise Python import statements. Used by Executor Agent after generating or modifying code.
language: python
used-by: executor
---

Update the import statements for the specified file.

Rules:
1. All imports at the top of the module — no inline imports except for circular dependencies or large conditional module loading
2. Group imports: stdlib → third-party → local (PEP 8), separated by blank lines
3. Use `isort`-compatible ordering within each group
4. Remove unused imports
5. Use explicit imports — never `from module import *`
6. Use absolute imports for all modules and packages
7. Use relative imports **only** in `__init__.py` re-exports from the same package
8. Aliases only when widely accepted (e.g. `import numpy as np`) — avoid unclear aliases
9. Do **not** add `from __future__ import annotations`. Resolve forward references with string literals (`"ClassName"`) or restructure the code

Output the complete updated import block, then list: added, removed, reorganised.

$ARGUMENTS
