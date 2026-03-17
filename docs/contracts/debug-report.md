# Contract: Debug Report

**Producer**: Debugger agent
**Consumer**: Executor agent

## Purpose

Root cause analysis and a minimal fix prescription. The Executor implements the fix exactly as specified — the Debugger does not write code.

## Schema

```markdown
## Debug Report

### Failure point
`<file>:<line>` — <what fails and how it manifests>

### Root cause
<explanation of why this happens — not just what, but why>

### Contributing factors
<environment, data shape, timing, version incompatibility, etc. — or "None">

### Fix
<file>:<line-range>

Before:
```<language>
<original code>
```

After:
```<language>
<fixed code>
```

Rationale: <why this fix is correct>

### Prevention
<test to add, validation to improve, or pattern to avoid to prevent recurrence>

### Confidence
HIGH | MEDIUM | LOW — <one line explaining confidence level>
```

## Field rules

| Section | Required | Notes |
|---------|----------|-------|
| Failure point | yes | Must include file and line |
| Root cause | yes | Must explain *why*, not just *what* |
| Contributing factors | yes | Use "None" if isolated |
| Fix | yes | Must include before/after code |
| Prevention | yes | At least one concrete action |
| Confidence | yes | LOW triggers a note to the user |

## Invariants

- Debugger must not implement the fix — only prescribe it
- Fix must be minimal: change only what is necessary to resolve the root cause
- If the bug is a symptom of a deeper design issue, note it in Prevention but keep the Fix minimal
- LOW confidence must be flagged clearly to the user before Executor proceeds
