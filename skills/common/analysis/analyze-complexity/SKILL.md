---
name: analyze-complexity
description: Analyse the cyclomatic and cognitive complexity of code. Used by Reviewer and Performance agents to identify functions that are too complex to safely modify or test.
language: common
used-by: context,planner,reviewer,performance
---

Analyse the complexity of the specified code.

For each function / method:
1. **Cyclomatic complexity**: count decision points (if/else/switch/loop/try/catch)
2. **Cognitive complexity**: estimate how hard it is to understand (nesting depth, non-linear jumps, recursion)
3. **Lines of code**: two-tier threshold —
   - > ~30 lines: "review carefully — consider extraction" (matches language-skill refactoring trigger)
   - > 50 lines: flag as a complexity issue (HIGH or MEDIUM depending on cyclomatic/cognitive score)
4. **Parameter count**: flag functions with more than 5 parameters

Output:
```
## Complexity Report

| Function | Cyclomatic | Cognitive | LOC | Params | Risk |
|----------|-----------|-----------|-----|--------|------|
| fn_name  | 12        | 18        | 87  | 4      | HIGH |

### High-risk functions (action required)
- `fn_name` (cyclomatic: 12) — consider extracting: <suggestion>

### Medium-risk functions (monitor)
- `fn_name` (cognitive: 8) — simplify by: <suggestion>
```

Thresholds: cyclomatic > 10 = HIGH; 5–10 = MEDIUM. Cognitive > 15 = HIGH; 7–15 = MEDIUM.

$ARGUMENTS
