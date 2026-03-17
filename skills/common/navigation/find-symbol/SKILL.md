---
name: find-symbol
description: Find where a symbol (function, class, type, constant) is defined. Used by Context and Planner agents to locate code before modifying it.
language: common
used-by: context,planner
---

Locate the definition of the specified symbol.

Steps:
1. Search for the symbol name across the codebase
2. Identify the canonical definition (not re-exports or aliases)
3. Note any overloads, implementations, or language-specific variants

Output:
- **Defined in**: `<file>:<line>`
- **Signature**: full function/class/type signature
- **Module path**: how to import it
- **Also exported via**: any re-export locations

$ARGUMENTS
