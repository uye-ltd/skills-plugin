---
name: map-project
description: Map the overall project structure. Used by Context Agent to understand where things live before diving into specific files.
language: common
used-by: context,planner
---

Explore the project root and produce a structural map.

Output:
1. **Directory tree** (top 3 levels, skip build artifacts and node_modules/.git/venv)
2. **Entry points**: main files, CLI entry points, server startup
3. **Key packages/modules**: purpose of each top-level directory in one line
4. **Config files**: what each config file controls
5. **Test layout**: where tests live and what framework is used

Keep it concise — this is a navigation aid, not exhaustive documentation.

$ARGUMENTS
