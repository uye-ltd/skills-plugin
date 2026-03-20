# Contract: Review Report

Produced by: Reviewer agent
Consumed by: Executor (on ITERATE), Refactorer (on PASS, when smells/complexity flagged), Debugger (on DEBUG), User (on BLOCKED)

## Fields

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| Decision | yes | enum: PASS, ITERATE, DEBUG, BLOCKED | Reviewer verdict |
| Issues found | yes | table | All issues found; use "No issues found" if clean |
| Security findings | yes | prose | Results of secrets-scan, owasp-check, input-validation; use "None" if clean |
| Test coverage assessment | yes | prose | Whether tests are adequate; list missing scenarios if not |
| Attempt history | conditional | list | Required on ITERATE: one line per prior iteration summarising what was tried and why it failed |
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
| needs-debug | no | bool | `true` if root cause is unknown and Debugger is needed |

## Decision Rules

The Reviewer MUST apply these rules in order:

| Condition | Decision |
|-----------|----------|
| Iteration count ≥ `maxIterations` AND any unresolved non-nit issue | `BLOCKED` |
| DEBUG decision count ≥ `maxDebugCycles` AND debug condition still present | `BLOCKED` |
| Any issue with severity = `critical` | `ITERATE` |
| `>= 3` issues with severity = `major` | `ITERATE` |
| Any issue flagged `needs-debug: true` (unclear root cause) | `DEBUG` |
| Test coverage < threshold AND new code added | `ITERATE` |
| All issues are `minor` or `nit` only | `PASS` |
| No issues found | `PASS` |

Rules are evaluated top-to-bottom; the first matching rule wins.

## Severity definitions

See `docs/severity-mappings.md` for full definitions and language-specific pattern tables.

## Refactorer invocation

After a `PASS` verdict, invoke the Refactorer if `detect-code-smells` or `analyze-complexity` flagged any findings during the review — even findings not severe enough to block. Note the specific findings in "Next step". If neither skill flagged anything, "Next step" may read "Done — no refactoring needed."

## Next step instructions

- `PASS` (with smells/complexity findings): "Hand off to Refactorer. Findings: <list>."
- `PASS` (clean): "Done — no refactoring needed."
- `ITERATE`: "Return to Executor. Fix: <specific instructions per issue>."
- `DEBUG`: "Escalate to Debugger. Symptom: <description>."
- `BLOCKED`: "Max iterations reached. Surfacing unresolved issues to user: <list all issues>."

## Multi-language variant

For multi-language tasks, produce per-language `### [Language] Issues found` and `### [Language] Security findings` sections. The Decision field is singular and applies the strictest verdict across all languages.

## Invariants

- Reviewer must not fix issues itself — only report
- Every issue must include file, line reference, and a concrete suggestion
- Issues table must be present even if empty (use "No issues found")
- Security findings section must be present even if clean (use "None")
- Decision must follow the rule table in order — no discretion on `critical` issues
- `BLOCKED` decision must list all unresolved issues so the user has full context
- `ITERATE` decision must include `Attempt history` section

## Example

```
## Review Report

### Decision: ITERATE

### Issues found
| Severity | File | Line | Issue | Suggestion | perf | needs-debug |
|----------|------|------|-------|------------|------|-------------|
| critical | src/auth.py | 42 | SQL query built via string concat | Use parameterised query | | |
| major | src/auth.py | 78 | Missing await on async DB call | Add await before db.query() | | |

### Test coverage assessment
No test for the error path when credentials are invalid. Add a test for 401 response.

### Next step
Return to Executor. Fix: (1) parameterise SQL at auth.py:42; (2) add await at auth.py:78.
```
