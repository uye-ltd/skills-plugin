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
| COMMON_SKILLS | yes | list[path] | Common skill directory paths (shared; emitted once per routing block) |
| PIPELINE | yes | key=value pairs | Pipeline flags read from settings.json |
| SKILLS_EXCLUDE | no | space-separated strings | Skill names (by `name` frontmatter) never to invoke; empty string means no exclusions |
| SKILLS_INCLUDE | no | space-separated strings | If non-empty, allowlist — agents may only invoke skills whose names appear here (within their normal skill set); empty string means no allowlist |
| AGENTS_DISABLED | no | space-separated strings | Optional-stage agents to skip: any of `refactorer`, `performance`, `debugger`; empty string means none disabled |
| NEXT | yes | enum: context | Always "context" |

### PIPELINE field format

```
PIPELINE: skipPlanner=<bool> skipReview=<bool> maxIterations=<int> maxDebugCycles=<int> contextMaxFiles=<int>
```

| Key | Default | Description |
|-----|---------|-------------|
| `skipPlanner` | `false` | Context hands off to Executor directly, skipping Planner |
| `skipReview` | `false` | Executor marks complete without invoking Reviewer |
| `maxIterations` | `3` | Maximum Executor↔Reviewer round trips before BLOCKED |
| `maxDebugCycles` | `2` | Maximum DEBUG decisions before Reviewer emits BLOCKED instead of DEBUG |
| `contextMaxFiles` | `20` | Maximum files Context agent reads; excess files are noted but skipped |
| `disableAgents` | `[]` | Optional-stage agents to skip: `refactorer`, `performance`, `debugger`. Does not apply to core pipeline agents (context, executor). |

## Invariants

- LANGUAGE must be one of the three supported values; if unknown set `LANGUAGE: unknown`, omit skill fields, and ask the user before proceeding
- Language-specific skill paths (e.g. `./skills/python/generation`) are not registered in plugin.json — they are routed dynamically. Only common skill paths appear in plugin.json.
- Multi-language tasks produce one routing block per language, each in its own fenced block; COMMON_SKILLS and PIPELINE are emitted once, after all per-language blocks; SKILLS_EXCLUDE, SKILLS_INCLUDE, and AGENTS_DISABLED are also emitted once in the shared block
- NEXT is always `context` — routing block is only ever the first step
- SKILLS_EXCLUDE and SKILLS_INCLUDE default to empty string when the settings keys are absent or empty arrays. An empty SKILLS_INCLUDE means no allowlist is active.
- AGENTS_DISABLED only accepts `refactorer`, `performance`, `debugger` — it does not apply to core pipeline agents (context, planner, executor, reviewer).
- Skill names in SKILLS_EXCLUDE and SKILLS_INCLUDE are matched against the `name` frontmatter field of each skill (e.g. `secrets-scan`, `py-code-review`).

## Example

```
LANGUAGE: python
REASON: pyproject.toml found at project root
EXECUTOR_SKILLS: ./skills/python/generation, ./skills/python/refactoring, ./skills/python/testing
REVIEWER_SKILLS: ./skills/python/analysis, ./skills/python/debugging
COMMON_SKILLS:   ./skills/common/navigation, ./skills/common/analysis
PIPELINE: skipPlanner=false skipReview=false maxIterations=3 maxDebugCycles=2 contextMaxFiles=20
SKILLS_EXCLUDE:
SKILLS_INCLUDE:
AGENTS_DISABLED:
NEXT: context
```

### Multi-language variant

```
LANGUAGE: go
REASON: backend files have .go extension
EXECUTOR_SKILLS: ./skills/go/generation, ./skills/go/refactoring, ./skills/go/testing
REVIEWER_SKILLS: ./skills/go/analysis, ./skills/go/debugging

LANGUAGE: javascript
REASON: frontend files have .ts/.tsx extension
EXECUTOR_SKILLS: ./skills/javascript/generation, ./skills/javascript/refactoring, ./skills/javascript/testing
REVIEWER_SKILLS: ./skills/javascript/analysis, ./skills/javascript/debugging

COMMON_SKILLS: ./skills/common/navigation, ./skills/common/analysis
PIPELINE: skipPlanner=false skipReview=false maxIterations=3 maxDebugCycles=2 contextMaxFiles=20
SKILLS_EXCLUDE:
SKILLS_INCLUDE:
AGENTS_DISABLED:
NEXT: context
```
