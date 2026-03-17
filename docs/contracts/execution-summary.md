# Contract: Execution Summary

**Producer**: Executor agent
**Consumer**: Reviewer agent

## Purpose

A record of what the Executor changed and why, produced after completing all plan steps. The Reviewer uses this alongside the actual diff to focus the review.

## Schema

```markdown
## Execution Summary

### Files changed
- `<relative/path/file.ext>`: <what changed and why>

### Deviations from plan
- Step <N>: <what changed from the plan and why> — or "None"

### New dependencies introduced
- <package@version>: <why it was needed> — or "None"

### Ready for review
- [ ] All plan steps complete
- [ ] No unintended files modified
- [ ] Imports updated
- [ ] No debug/temporary code left in
```

## Field rules

| Section | Required | Notes |
|---------|----------|-------|
| Files changed | yes | One bullet per file |
| Deviations from plan | yes | Use "None" if plan was followed exactly |
| New dependencies | yes | Use "None" if no new deps |
| Ready for review checklist | yes | All items must be checked |

## Invariants

- Executor must only modify files listed in the Implementation Plan or directly required by plan steps (e.g. imports in a consuming file)
- Any out-of-scope change must be listed as a deviation with justification
- If the Executor cannot complete a step, it must stop and report — not skip silently
