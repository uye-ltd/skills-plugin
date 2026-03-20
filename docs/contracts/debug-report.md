# Contract: Debug Report

Produced by: Debugger agent
Consumed by: Executor agent (on normal report), User (on BLOCKED)

## Fields

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| Failure point | yes | file:line + prose | What fails and how it manifests |
| Root cause | yes | prose | Why this happens — not just what, but why |
| Contributing factors | yes | prose | Environment, data shape, timing, version issues; use "None" if isolated |
| Fix | yes | before/after code block | Minimal code change to resolve the root cause |
| Prevention | yes | prose | Test to add, validation to improve, or pattern to avoid |
| Confidence | yes | enum: HIGH, MEDIUM, LOW + explanation | LOW must be flagged clearly to the user |

## BLOCKED variant

If root cause cannot be determined, emit a BLOCKED report instead of the standard fields:

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| Status | yes | literal: BLOCKED | Signals investigation is stalled |
| What was attempted | yes | prose | Investigation steps taken |
| Missing information | yes | prose | What is needed to identify the root cause |
| Question for user | yes | prose | One concrete question that would unblock investigation |

A BLOCKED report is surfaced directly to the user — it does not route to the Executor.

## Invariants

- Debugger must not implement the fix — only prescribe it
- Fix must be minimal: change only what is necessary to resolve the root cause
- If the bug is a symptom of a deeper design issue, note it in Prevention but keep Fix minimal
- LOW confidence must be flagged clearly to the user before Executor proceeds
- Root cause must explain *why*, not just *what*
- If root cause is unknown, emit BLOCKED — do not guess

## Example

```markdown
## Debug Report

### Failure point
`src/auth/login.py:42` — KeyError raised when user has no `last_login` field in session dict

### Root cause
The session dict is created in `src/auth/session.py:18` but `last_login` is only set on subsequent logins.
First-time users never have this key, so direct dict access at login.py:42 raises KeyError.

### Contributing factors
Only affects first-time logins — accounts created before the `last_login` field was added also exhibit this.

### Fix
`src/auth/login.py:42`

Before:
```python
last = session["last_login"]
```

After:
```python
last = session.get("last_login")
```

Rationale: `.get()` returns None safely when the key is absent; downstream code already handles None.

### Prevention
Add a test for first-time login that asserts no KeyError is raised.
Consider initialising `last_login: None` in session creation (src/auth/session.py:18) to make the contract explicit.

### Confidence
HIGH — reproduces deterministically on first-time login; fix is one-line and safe.
```
