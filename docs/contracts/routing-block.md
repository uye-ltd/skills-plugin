# Contract: Routing Block

**Producer**: Language Router agent
**Consumer**: Context agent (and all downstream agents that need language context)

## Purpose

Establishes the language context for the entire pipeline run. Emitted once at the start of every task. All downstream agents read the `LANGUAGE` field to select the correct language-specific skills.

## Schema

```
LANGUAGE: <python|javascript|go|unknown>
REASON:   <one line explaining the detection basis>
EXECUTOR SKILLS: skills/<language>/generation/, skills/<language>/refactoring/
REVIEWER SKILLS: skills/<language>/analysis/, skills/<language>/debugging/
COMMON SKILLS:   skills/common/navigation/, skills/common/analysis/
NEXT: context-agent
```

## Field rules

| Field | Required | Values |
|-------|----------|--------|
| `LANGUAGE` | yes | `python` / `javascript` / `go` / `unknown` |
| `REASON` | yes | Free text, one line |
| `EXECUTOR SKILLS` | yes | Comma-separated relative paths |
| `REVIEWER SKILLS` | yes | Comma-separated relative paths |
| `COMMON SKILLS` | yes | Comma-separated relative paths |
| `NEXT` | yes | Always `context-agent` |

## Multi-language variant

When the task spans multiple languages, emit one block per language:

```
LANGUAGE: go
REASON:   backend files have .go extension
EXECUTOR SKILLS: skills/go/generation/, skills/go/refactoring/
REVIEWER SKILLS: skills/go/analysis/, skills/go/debugging/
COMMON SKILLS:   skills/common/navigation/, skills/common/analysis/
NEXT: context-agent

LANGUAGE: javascript
REASON:   frontend files have .ts/.tsx extension
EXECUTOR SKILLS: skills/javascript/generation/, skills/javascript/refactoring/
REVIEWER SKILLS: skills/javascript/analysis/, skills/javascript/debugging/
COMMON SKILLS:   skills/common/navigation/, skills/common/analysis/
NEXT: context-agent
```

## Unknown language

If language cannot be detected, set `LANGUAGE: unknown`, omit skill fields, and ask the user before proceeding.
