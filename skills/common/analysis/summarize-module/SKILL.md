---
name: summarize-module
description: Summarize what a module or file does. Used by Context and Planner to build a mental model without reading every line.
language: common
used-by: context,planner,reviewer,performance
---

Produce a concise technical summary of the specified module.

Cover:
- **Purpose**: what problem this module solves (one paragraph)
- **Public API**: exported symbols with one-line descriptions
- **Internal structure**: key private functions and their roles
- **State**: any module-level state, globals, or singletons
- **Side effects**: I/O, network calls, DB access, or other side effects
- **Dependencies**: key imports and what they contribute
- **Invariants**: any assumptions or contracts the module relies on

Keep the summary short enough to fit in a planning prompt — this is a navigation aid.

$ARGUMENTS
