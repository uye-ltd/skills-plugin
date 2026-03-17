# Contract: Review Report

**Producer**: Reviewer agent
**Consumer**: Executor (on ITERATE), Refactorer (on PASS), Debugger (on DEBUG)

## Purpose

The Reviewer's verdict on the Executor's output. Drives the pipeline's iteration decision. A single `critical` issue always results in ITERATE.

## Schema

```markdown
## Review Report

### Decision: PASS | ITERATE | DEBUG

### Issues found
| Severity | File | Line | Issue | Suggestion |
|----------|------|------|-------|------------|
| critical | path/file.ext | 42 | description | fix suggestion |
| major    | ...           | .. | ...         | ...          |
| minor    | ...           | .. | ...         | ...          |
| nit      | ...           | .. | ...         | ...          |

### Test coverage assessment
<are the tests adequate? list specific missing scenarios if not>

### Next step
<exact instruction for the next agent>
```

## Severity definitions

| Severity | Meaning | Triggers |
|----------|---------|---------|
| `critical` | Correctness bug, security issue, or broken contract | Always ITERATE |
| `major` | Design problem, missing error handling, poor testability | Usually ITERATE |
| `minor` | Style, naming, missing docs | May be deferred |
| `nit` | Cosmetic, personal preference | Never blocks |

## Decision rules

| Condition | Decision |
|-----------|----------|
| Any `critical` issue | ITERATE |
| `major` issues only | ITERATE (default) or PASS at reviewer discretion |
| `minor` / `nit` only | PASS |
| Root cause unclear | DEBUG |
| All criteria met | PASS |

## Next step instructions

- `PASS`: "Hand off to Refactorer for optional cleanup." or "Done — no refactoring needed."
- `ITERATE`: "Return to Executor. Fix: <specific instructions per issue>."
- `DEBUG`: "Escalate to Debugger. Symptom: <description>."

## Invariants

- Reviewer must not fix issues itself — only report
- Every issue must include file, line reference, and a concrete suggestion
- Issues table must be present even if empty (use "No issues found")
