---
name: extract-api
description: Extract the public API surface of a module or package. Used by Context Agent to understand contracts before modifying internals.
language: common
used-by: context,planner,reviewer,performance
---

Extract and document the complete public API of the specified module or package.

For each exported symbol, provide:
- **Name** and kind (function / class / type / constant)
- **Signature**: parameters, types, return type
- **Brief description**: what it does
- **Stability**: any deprecation notices or stability markers

Output format:
```
## Public API: <module name>

### Functions
- `fn_name(param: Type) -> ReturnType` — description

### Classes
- `ClassName` — description
  - `method(param: Type) -> ReturnType` — description

### Types / Interfaces
- `TypeName = ...` — description

### Constants
- `CONST_NAME: Type = value` — description
```

Flag anything that looks like accidental exposure of internal symbols.

$ARGUMENTS
