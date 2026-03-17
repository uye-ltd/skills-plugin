---
name: find-references
description: Find all references to a symbol across the codebase. Used by Planner to assess blast radius before proposing changes.
language: common
used-by: context,planner
---

Find every location that references the specified symbol.

Steps:
1. Search for all usages (calls, instantiations, type references, imports)
2. Group by file and usage type (call-site / type annotation / re-export / test)
3. Identify any dynamic usage patterns that static search might miss

Output:
- **Total references**: N across M files
- **By file**: grouped list with line numbers and usage type
- **Risk assessment**: which references would break if the symbol's signature changed
- **Test coverage**: which references have corresponding tests

$ARGUMENTS
