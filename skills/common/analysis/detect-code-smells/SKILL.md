---
name: detect-code-smells
description: Detect code smells across a file or module. Used by Reviewer to flag structural problems beyond correctness bugs.
language: common
used-by: context,planner,reviewer,performance
---

Identify code smells in the specified code.

Check for:
- **Long functions**: functions over 50 lines doing more than one thing
- **Long parameter lists**: more than 4–5 parameters (suggest a config object/struct)
- **Deep nesting**: more than 3 levels of indentation
- **Duplicated logic**: copy-pasted code blocks that should be extracted
- **Dead code**: unreachable or unused code paths
- **Magic numbers/strings**: unexplained literals (should be named constants)
- **God object/function**: one unit doing too many unrelated things
- **Primitive obsession**: passing raw strings/ints where a type/struct would be clearer
- **Feature envy**: a function that uses another module's data more than its own
- **Inappropriate intimacy**: two modules knowing too much about each other's internals

Output: grouped list by severity with file, line, smell name, and a concrete refactoring suggestion. Use these severity labels consistently:

| Severity | Smells |
|----------|--------|
| `critical` | God object/function doing many unrelated things AND >200 lines — immediate refactoring required |
| `major` | God object/function (>200 lines), deep nesting (>3 levels), long parameter lists (>5), feature envy, inappropriate intimacy |
| `minor` | Long functions (>50 lines), duplicated logic, dead code, magic numbers/strings, primitive obsession |
| `nit` | Slight verbosity, cosmetic duplication, minor naming inconsistency |

$ARGUMENTS
