# Contract: Routing Block

Produced by: Language Router
Consumed by: Context, Planner, Executor, Reviewer, Debugger, Refactorer, Performance

## Fields

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| LANGUAGE | yes | enum: python, javascript, go | Detected target language |
| REASON | yes | string | Why this language was selected (one line) |
| EXECUTOR_SKILLS | yes | list[path] | Skill directory paths for Executor |
| REVIEWER_SKILLS | yes | list[path] | Skill directory paths for Reviewer |
| COMMON_SKILLS | yes | list[path] | Common skill directory paths |
| NEXT | yes | enum: context | Always "context" |

## Invariants

- LANGUAGE must be one of the three supported values; if unknown set `LANGUAGE: unknown`, omit skill fields, and ask the user before proceeding
- All skill paths must exist in plugin.json
- Multi-language tasks produce one routing block per language, each in its own fenced block
- NEXT is always `context` — routing block is only ever the first step

## Example

```
LANGUAGE: python
REASON: pyproject.toml found at project root
EXECUTOR_SKILLS: ./skills/python/generation, ./skills/python/refactoring
REVIEWER_SKILLS: ./skills/python/analysis, ./skills/python/debugging
COMMON_SKILLS: ./skills/common/navigation, ./skills/common/analysis
NEXT: context
```

### Multi-language variant

```
LANGUAGE: go
REASON: backend files have .go extension
EXECUTOR_SKILLS: ./skills/go/generation, ./skills/go/refactoring
REVIEWER_SKILLS: ./skills/go/analysis, ./skills/go/debugging
COMMON_SKILLS: ./skills/common/navigation, ./skills/common/analysis
NEXT: context

LANGUAGE: javascript
REASON: frontend files have .ts/.tsx extension
EXECUTOR_SKILLS: ./skills/javascript/generation, ./skills/javascript/refactoring
REVIEWER_SKILLS: ./skills/javascript/analysis, ./skills/javascript/debugging
COMMON_SKILLS: ./skills/common/navigation, ./skills/common/analysis
NEXT: context
```
