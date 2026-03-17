# Contract: Execution Summary

Produced by: Executor agent
Consumed by: Reviewer agent

## Fields

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| Files changed | yes | list | One bullet per file: `path: what changed and why` |
| Deviations from plan | yes | list | Each deviation with justification; use "None" if plan followed exactly |
| New dependencies introduced | yes | list | `package@version: why needed`; use "None" if none |
| Ready for review checklist | yes | checklist | All items must be checked before handing off |

### Ready for review checklist items

- All plan steps complete
- No unintended files modified
- Imports updated
- No debug/temporary code left in

## Invariants

- Executor must only modify files listed in the Implementation Plan or directly required by plan steps (e.g. imports in a consuming file)
- Any out-of-scope change must be listed as a deviation with justification
- If the Executor cannot complete a step, it must stop and report — not skip silently
- All checklist items must be checked (not just present)

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
