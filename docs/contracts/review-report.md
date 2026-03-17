# Contract: Review Report

Produced by: Reviewer agent
Consumed by: Executor (on ITERATE), Refactorer (on PASS), Debugger (on DEBUG)

## Fields

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| Decision | yes | enum: PASS, ITERATE, DEBUG | Reviewer verdict |
| Issues found | yes | table | All issues found; use "No issues found" if clean |
| Test coverage assessment | yes | prose | Whether tests are adequate; list missing scenarios if not |
| Next step | yes | prose | Exact instruction for the next agent |

### Issues table columns

| Column | Required | Type | Description |
|--------|----------|------|-------------|
| Severity | yes | enum: critical, major, minor, nit | Issue severity |
| File | yes | path | File containing the issue |
| Line | yes | number | Line number |
| Issue | yes | string | Description of the issue |
| Suggestion | yes | string | Concrete fix suggestion |
| perf | no | bool | `true` if issue is performance-related (used by Performance agent) |

## Decision Rules

The Reviewer MUST apply these rules in order:

| Condition | Decision |
|-----------|----------|
| Any issue with severity = `critical` | `ITERATE` |
| `>= 3` issues with severity = `major` | `ITERATE` |
| Any issue flagged `needs-debug: true` (unclear root cause) | `DEBUG` |
| Test coverage < threshold AND new code added | `ITERATE` |
| All issues are `minor` or `nit` only | `PASS` |
| No issues found | `PASS` |

Rules are evaluated top-to-bottom; the first matching rule wins.

## Severity definitions

| Severity | Meaning |
|----------|---------|
| `critical` | Correctness bug, security issue, or broken contract |
| `major` | Design problem, missing error handling, poor testability |
| `minor` | Style, naming, missing docs |
| `nit` | Cosmetic, personal preference |

## Next step instructions

- `PASS`: "Hand off to Refactorer for optional cleanup." or "Done — no refactoring needed."
- `ITERATE`: "Return to Executor. Fix: <specific instructions per issue>."
- `DEBUG`: "Escalate to Debugger. Symptom: <description>."

## Invariants

- Reviewer must not fix issues itself — only report
- Every issue must include file, line reference, and a concrete suggestion
- Issues table must be present even if empty (use "No issues found")
- Decision must follow the rule table in order — no discretion on `critical` issues

## Example

```
## Review Report

### Decision: ITERATE

### Issues found
| Severity | File | Line | Issue | Suggestion | perf |
|----------|------|------|-------|------------|------|
| critical | src/auth.py | 42 | SQL query built via string concat | Use parameterised query | |
| major | src/auth.py | 78 | Missing await on async DB call | Add await before db.query() | |

### Test coverage assessment
No test for the error path when credentials are invalid. Add a test for 401 response.

### Next step
Return to Executor. Fix: (1) parameterise SQL at auth.py:42; (2) add await at auth.py:78.
```
