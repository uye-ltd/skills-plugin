# Contract: Implementation Plan

Produced by: Planner agent
Consumed by: Executor agent

## Fields

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| Objective | yes | string (one sentence) | The end state after all steps complete |
| Steps | yes | ordered list | At least one step; each references a specific file |
| Risks / edge cases | yes | list | Use "None identified" if none |
| Definition of done | yes | checklist | At least two verifiable criteria |

### Step format

Each step must follow: `[relative/path/file.ext] <ActionVerb> — <why>`

Valid action verbs: `Add`, `Modify`, `Create`, `Delete`, `Move`, `Rename`

The "why" explains the business or design reason, not the implementation detail. If a step depends on a prior step, note it: `(depends on step N)`.

## Multi-language variant

For multi-language tasks, prefix each step with the language in brackets: `[Go]`, `[JavaScript]`, etc. Cross-language contract steps (e.g. defining a shared API shape) must appear before language-specific steps that depend on them. The Risks section must include a cross-language compatibility item.

## Invariants

- Planner must not write code
- Steps must be independently verifiable — each should leave the code in a runnable state
- Maximum step scope: one logical concern per step, one file where possible
- Every file referenced in steps must exist on disk or be explicitly created by a prior step
- In multi-language plans, dependency between steps of different languages must be made explicit

## Example

```markdown
## Implementation Plan

### Objective
Add rate limiting to the login endpoint to prevent brute-force attacks.

### Steps
1. [src/auth/rate_limit.py] Create — define `RateLimiter` class backed by Redis with a sliding window counter
2. [src/auth/login.py] Modify — inject `RateLimiter` and reject requests exceeding 5 attempts/minute (depends on step 1)
3. [tests/auth/test_rate_limit.py] Create — unit tests for `RateLimiter` and integration test for the 429 response (depends on step 1)

### Risks / edge cases
- Redis unavailable: decide whether to fail open (allow login) or fail closed (reject). Decision: fail open with warning log.
- Clock skew across instances: sliding window is atomic in Redis so this is safe.

### Definition of done
- [ ] Login returns 429 after 5 failed attempts within 60 seconds
- [ ] All existing auth tests pass
- [ ] RateLimiter is unit-tested with a mock Redis
- [ ] Reviewer approves
```
