---
name: read-file
description: Read and understand a specific file. Used by Context Agent to build a complete picture of files relevant to the current task.
language: common
used-by: context,planner
---

Read the specified file and produce a structured summary.

Output:
- **Purpose**: what this file does in one sentence
- **Public surface**: exported functions, classes, constants, types
- **Key dependencies**: what it imports and why
- **Notable patterns**: anything non-obvious about how it is structured

Then show the full file content with line numbers for reference.

$ARGUMENTS
