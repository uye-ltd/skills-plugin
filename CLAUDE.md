# CLAUDE.md — uye Claude Code Plugin

This is the organisation-wide Claude Code plugin for uye projects.
It implements a multi-agent pipeline with language routing for Python, JavaScript, and Go.

## Architecture

The pipeline is a sequence of specialised agents that hand off structured output to each other:

```
Language Router → Context → Planner → Executor → Reviewer
                                                     │
                                         ┌───────────┼───────────┐
                                         ▼           ▼           ▼
                                     Refactorer   Debugger   Performance*
                                                     │
                                                     ▼
                                                 Executor (loop)

* Performance triggers when:
  - Reviewer raises ≥ 2 major perf issues, OR
  - pipeline.autoPerformance: true in settings.json, OR
  - Planner detects a hot path, OR
  - User explicitly requests it
```

**Key principle**: agents are language-agnostic. Language Router selects the correct
skill set for Executor and Reviewer. All other agents use common skills only.

## Configuration

`settings.json` at the plugin root controls default behaviour. Projects can override by shipping their own `settings.json` alongside `.claude-plugin/plugin.json`.

| Key | Default | Description |
|-----|---------|-------------|
| `agent` | `"language-router"` | Entry-point agent for all requests |
| `outputStyle` | `"Explanatory"` | Response verbosity: `Explanatory` \| `Concise` |
| `language` | `null` | Pin language; skips auto-detection in Language Router |
| `pipeline.skipReview` | `false` | Skip Reviewer agent (prototyping only) |
| `pipeline.skipPlanner` | `false` | Skip Planner for small tasks |
| `pipeline.autoPerformance` | `false` | Run Performance agent automatically after every PASS |

## Repository layout

```
.claude-plugin/plugin.json   — manifest: name, version, skill paths, hooks path
agents/                      — one .md file per agent (system prompt + frontmatter)
skills/
  common/                    — skills used by all agents regardless of language
    navigation/              — read-file, map-project, find-symbol, …
    analysis/                — summarize-module, extract-api, …
    performance/             — suggest-cache, detect-n-plus-one
    security/                — infra/boundary-level: owasp-check, input-validation, …
    docs/                    — docs-write, docs-review, …
    devops/                  — dockerfile, ci-pipeline, k8s, …
  python/ javascript/ go/    — language-specific skills
    analysis/                — code-review, check-bugs  (used by Reviewer)
    generation/              — generate-func, …         (used by Executor)
    refactoring/             — extract-func, …          (used by Refactorer)
    testing/                 — generate-test, …         (used by Executor + Reviewer)
    debugging/               — analyze-trace, …         (used by Debugger)
    performance/             — language-specific perf   (used by Performance)
  templates/                 — base templates for parallel skill families (analyze-trace, detect-bugs, …)
docs/contracts/              — input/output schemas for each agent handoff
hooks/hooks.json             — hook configuration (JSONC)
scripts/                     — install, scaffold, validate, release utilities
```

## Agent handoff contracts

Every agent produces a structured output block. The schema for each is in `docs/contracts/`.
Do not change the section headers in agent outputs — downstream agents parse them by name.

| Handoff | Contract file |
|---------|--------------|
| Language Router → Context | `docs/contracts/routing-block.md` |
| Context → Planner | `docs/contracts/context-summary.md` |
| Planner → Executor | `docs/contracts/implementation-plan.md` |
| Executor → Reviewer | `docs/contracts/execution-summary.md` |
| Reviewer → next | `docs/contracts/review-report.md` |
| Debugger → Executor | `docs/contracts/debug-report.md` |
| Refactorer → done | `docs/contracts/refactoring-summary.md` |
| Performance → done | `docs/contracts/performance-report.md` |

## Writing skills

Skills live at `skills/<language>/<subcategory>/<skill-name>/SKILL.md`.

Required frontmatter fields:
```yaml
---
name: <language>-<skill-name>        # unique across the plugin; prefix with language
description: <what it does and when Claude should invoke it>
language: python | javascript | go | common
used-by: executor | reviewer | refactorer | debugger | performance | context | planner | standalone
# template: <template-name>          # optional — references skills/templates/<name>.md
# disable-model-invocation: false    # optional — set true to prevent auto-invocation
---
```

Rules:
- Skill names are prefixed with language: `py-generate-func`, `go-check-goroutine`, `js-add-types`
- Common skills have no prefix: `read-file`, `detect-code-smells`
- The `description` is used by Claude to decide when to invoke the skill — be specific
- `$ARGUMENTS` captures user-provided input; always include it at the end of the prompt
- Keep prompts actionable: tell Claude what to do, what to output, what format to use
- If a skill is part of a parallel family (e.g. `analyze-trace` exists in py/js/go), set `template:` to the shared base in `skills/templates/` and keep only language-specific details in the skill body. `validate.sh` checks that the referenced template exists.

Scaffold: `./scripts/new-skill.sh <language|common> <subcategory> <skill-name>`

## Writing agents

Agents live at `agents/<name>.md`.

Required frontmatter:
```yaml
---
name: <agent-name>
description: <specialisation and when Claude should invoke it — be specific>
---
```

Rules:
- The `description` determines when Claude hands off to this agent — make it unambiguous
- Always document which skills the agent uses in the body
- Always define the output format the agent produces (matches its contract in `docs/contracts/`)
- Agents must not overlap in responsibility — each owns exactly one pipeline stage

Scaffold: `./scripts/new-agent.sh <name>`

## Adding a new language

Use the scaffold script — it creates all 6 subcategories and registers paths in `plugin.json`:

```bash
./scripts/new-language.sh <language-name>
# Example: ./scripts/new-language.sh rust
```

Then fill in the generated placeholder SKILL.md files.

## Adding a new common category

```bash
./scripts/new-category.sh <category-name> [skill1 skill2 ...]
# Example: ./scripts/new-category.sh accessibility contrast-check keyboard-nav
```

## Testing changes

```bash
# Validate plugin structure:
#   - frontmatter (name, description, language, used-by)
#   - template: references exist in skills/templates/
#   - all skill paths in plugin.json exist on disk
#   - each pipeline agent has a matching contract in docs/contracts/
#   - hook scripts are executable
./scripts/validate.sh
./scripts/validate.sh --strict    # treat warnings as errors

# List all registered skills
./scripts/list-skills.sh
./scripts/list-skills.sh python                  # filter by language
./scripts/list-skills.sh --used-by executor      # filter by consuming agent
./scripts/list-skills.sh --names-only            # just skill names

# Test plugin locally without installing
claude --plugin-dir /path/to/skills-plugin

# Reload in an active session after edits
/reload-plugins
```

## Hooks

Hooks are configured in `hooks/hooks.json` (JSONC). Hook scripts live in `scripts/hooks/`
and must be executable. Two hooks are active:

- **Python** (`format-python.sh`): runs `ruff format` + `ruff check --fix` after any Write or Edit to a `.py`/`.pyi` file
- **JavaScript** (`format-js.sh`): runs after any Write or Edit to a `.js`/`.ts`/`.jsx`/`.tsx` file

When adding a new language, `./scripts/new-language.sh` creates a stub hook script at `scripts/hooks/format-<language>.sh` automatically.

## Releasing

```bash
./scripts/release.sh <version>
# Example: ./scripts/release.sh 2.1.0
# Updates plugin.json version, prepends CHANGELOG entry, shows next steps
```

## Conventions

- Skill names: `kebab-case`, prefixed with language code (`py-`, `js-`, `go-`) or unprefixed for common
- Agent names: `kebab-case`, role-based (not language-based)
- Script names: `kebab-case` verbs (`new-skill.sh`, `validate.sh`, `list-skills.sh`)
- All scripts must start with `set -euo pipefail` and include a usage comment
- Do not hardcode absolute paths in scripts — use `PLUGIN_DIR` derived from `${BASH_SOURCE[0]}`
