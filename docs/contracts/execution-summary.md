# Contract: Execution Summary

Produced by: Executor agent
Consumed by: Reviewer agent (or done if skipReview=true)

## Fields

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| Iteration | yes | integer | Round-trip count (1 on first run; increments on each ITERATE) |
| Files changed | yes | list | One bullet per file: `path: what changed and why` |
| Changes | yes | per-file diff | Before/after snippet for each logical change (see format below) |
| Deviations from plan | yes | list | Each deviation with justification; use "None" if plan followed exactly |
| New dependencies introduced | yes | list | `package@version: why needed`; use "None" if none |
| Ready for review checklist | yes | checklist | All items must be checked before handing off |

### Changes format

For each file modified, include a before/after block limited to the changed lines (±5 lines context):

```
#### path/to/file.ext
Before:
```<lang>
<original lines>
```
After:
```<lang>
<new lines>
```
```

For new files, include the full file content instead of a before/after block.

### Ready for review checklist items

- All plan steps complete
- No unintended files modified
- Imports updated
- No debug/temporary code left in

## Multi-language variant

For multi-language tasks, prefix each section with the language: `### [Go] Files changed`, `### [JavaScript] Files changed`, etc. The Iteration and checklist fields are shared (not per-language).

## Invariants

- Executor must only modify files listed in the Implementation Plan or directly required by plan steps (e.g. imports in a consuming file)
- Any out-of-scope change must be listed as a deviation with justification
- If the Executor cannot complete a step, it must stop and report — not skip silently
- All checklist items must be checked (not just present)
- `Iteration` must be present and accurate — Reviewer uses it to enforce `maxIterations`
- `Changes` section must be present for every modified file — Reviewer must not re-read full files to conduct a review

## Example

```markdown
## Execution Summary

### Files changed
- `src/auth/rate_limit.py`: created RateLimiter class with sliding window counter backed by Redis
- `src/auth/login.py`: injected RateLimiter; added 429 response on limit exceeded
- `tests/auth/test_rate_limit.py`: 6 unit tests for RateLimiter, 1 integration test for 429

### Deviations from plan
- Step 3: also added a fixture `redis_client` to `tests/conftest.py` — required for test isolation, not anticipated in plan

### New dependencies introduced
- None

### Ready for review
- [x] All plan steps complete
- [x] No unintended files modified
- [x] Imports updated
- [x] No debug/temporary code left in
```
