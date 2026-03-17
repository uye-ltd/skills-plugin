# Contract: Context Summary

Produced by: Context agent
Consumed by: Planner agent

## Fields

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| Language | yes | enum: python, javascript, go | Copied from Routing Block |
| Files involved | yes | list | At least one entry: `path: one-line purpose` |
| Key symbols | conditional | list | Required when specific symbols are relevant; omit if none |
| Relevant API surface | conditional | prose | Required when public interface is affected |
| Dependencies and constraints | yes | prose | Use "None identified" if none |
| Open questions | yes | prose | Use "None" if none |

## Invariants

- Context Agent must not make any code changes — read only
- All file references must use relative paths from the project root
- If a file is too large to summarise fully, note which sections were skipped and why
- Language value must be copied verbatim from the Routing Block

## Example

```markdown
## Context Summary

### Language
python

### Files involved
- src/auth/login.py: handles login form submission and session creation
- src/auth/models.py: User model definition with password hashing

### Key symbols
- `User.authenticate`: defined in `src/auth/models.py:34`, used by `src/auth/login.py:12`
- `hash_password`: defined in `src/auth/utils.py:5`, used by `src/auth/models.py:40`

### Relevant API surface
`User.authenticate(username: str, password: str) -> Optional[User]`
Returns None on failure; raises ValueError if username is empty.

### Dependencies and constraints
- Must not break existing session token format (backwards compat with mobile clients)
- `bcrypt` version pinned to 4.0.x in pyproject.toml

### Open questions
- Should failed login attempts be rate-limited? Planner should decide before adding the endpoint.
```
