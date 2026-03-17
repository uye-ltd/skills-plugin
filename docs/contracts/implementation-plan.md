# Contract: Implementation Plan

**Producer**: Planner agent
**Consumer**: Executor agent

## Purpose

A concrete, ordered list of steps for the Executor to follow. Each step is atomic, references a specific file, and states what to do and why. The Executor must not deviate from the plan.

## Schema

```markdown
## Implementation Plan

### Objective
<one sentence describing the end state>

### Steps
1. [<relative/path/file.ext>] <action verb> — <why>
2. [<relative/path/file.ext>] <action verb> — <why>
...

### Risks / edge cases
- <risk description>: <mitigation>

### Definition of done
- [ ] <verifiable criterion>
- [ ] All existing tests pass
- [ ] Reviewer approves
```

## Field rules

| Section | Required | Notes |
|---------|----------|-------|
| Objective | yes | One sentence only |
| Steps | yes | At least one; ordered by dependency |
| Risks / edge cases | yes | Use "None identified" if none |
| Definition of done | yes | At least two criteria |

## Step format rules

- Each step starts with `[file/path]` — must be a real file or a file to be created
- Action verbs: `Add`, `Modify`, `Create`, `Delete`, `Move`, `Rename`
- The "why" explains the business/design reason, not the implementation detail
- If a step depends on a previous step completing first, note it: `(depends on step 2)`

## Invariants

- Planner must not write code
- Steps must be independently verifiable — each should leave the code in a runnable state
- Maximum step scope: one logical concern per step, one file where possible
