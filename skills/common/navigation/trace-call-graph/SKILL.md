---
name: trace-call-graph
description: Trace the call graph from an entry point. Used by Planner to understand chains of execution and assess the blast radius of proposed changes.
language: common
used-by: context,planner
---

Trace all functions called transitively from the specified entry point.

Steps:
1. Start from the entry point
2. Recursively map all direct and indirect callees (up to 5 levels deep, or until leaf functions)
3. Identify external calls (DB, network, file I/O, external services)
4. Note any cycles or recursive calls

Output:
```
<entry_point>
├── <callee_1> (<file>:<line>)
│   ├── <callee_1a>
│   └── <callee_1b> [DB call]
└── <callee_2> (<file>:<line>)
    └── <callee_2a> [external HTTP]
```

Highlight functions that cross module or service boundaries — these are the highest-risk change points.

$ARGUMENTS
