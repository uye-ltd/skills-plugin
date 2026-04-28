# CLAUDE.md — uye Claude Code Plugin

This is the organisation-wide Claude Code plugin for uye projects.
It implements a multi-agent pipeline with language routing for Python, JavaScript, and Go.

## Architecture

The pipeline is a sequence of specialised agents that hand off structured output to each other:

```
Language Router → Context → Planner → Executor → Reviewer (+ security gate)
                              │                      │
                    skipPlanner=true          ┌──────┼──────────┐
                    (goes direct)             ▼      ▼          ▼
                                         Refactorer† Debugger‡  Performance*
                                         (verify-    │           │ FIX_NOW
                                          tests)     ▼           ▼
                                                  Executor ← Executor
                                                  (loop, up to maxIterations)
                                                      │
                                               BLOCKED → User

† Refactorer: invoked after PASS if detect-code-smells or analyze-complexity flagged anything.
  Invokes verify-tests after each step. Skipped (Done) if both skills are clean.

‡ Debugger: guarded by maxDebugCycles. Emits BLOCKED (not a guess) when root cause is unknown.

* Performance: FIX_NOW routes a structured fix request to Executor → Reviewer.
  MEASURE_FIRST surfaces profiling commands to user without touching code.
  Auto-triggers: Reviewer ≥ 2 major perf issues; autoPerformance=true; Planner hot path; user request.
```

**Key principle**: agents are language-agnostic. Language Router selects the correct
skill set for Executor and Reviewer. All other agents use common skills only.

## Configuration

`settings.json` at the plugin root controls default behaviour. Projects can override by shipping their own `settings.json` alongside `.claude-plugin/plugin.json`.

| Key | Default | Description |
|-----|---------|-------------|
| `agent` | `"language-router"` | Entry-point agent for all requests |
| `outputStyle` | `"Explanatory"` | Response verbosity: `Explanatory` \| `Concise` |
| `lang` | `null` | Pin programming language; takes priority over all detection rules |
| `pipeline.skipReview` | `false` | Skip Reviewer agent (prototyping only) |
| `pipeline.skipPlanner` | `false` | Skip Planner; Context hands off directly to Executor |
| `pipeline.autoPerformance` | `false` | Run Performance agent automatically after every PASS |
| `pipeline.maxIterations` | `3` | Max Executor↔Reviewer round trips before `BLOCKED` |
| `pipeline.maxDebugCycles` | `2` | Max DEBUG decisions before Reviewer emits `BLOCKED` instead of re-escalating |
| `pipeline.disableAgents` | `[]` | Optional-stage agents to skip: `refactorer`, `performance`, `debugger`. Does not apply to core agents. |
| `context.maxFiles` | `20` | Max files Context agent reads fully; extras are noted but skipped |
| `tools` | `[]` | Enable reference skills: `["postgres", "redis"]`. Supports version pinning: `[{"name": "redis", "version": "7.2"}]` — overrides `github.branch` for source lookups |
| `skills.exclude` | `[]` | Skill names (by `name` frontmatter) never to invoke across all agents. E.g. `["secrets-scan", "py-check-bugs"]` |
| `skills.include` | `[]` | If non-empty, allowlist — agents only invoke skills in this list (within their normal set). Does not grant access to out-of-role skills. |

## Repository layout

```
.claude-plugin/plugin.json   — manifest: name, version, skill paths, agent paths
agents/                      — one .md file per agent (system prompt + frontmatter)
skills/
  common/                    — skills used by all agents regardless of language
    navigation/              — read-file, map-project, find-symbol, …
    analysis/                — summarize-module, extract-api, …
    performance/             — suggest-cache, detect-n-plus-one
    security/                — infra/boundary-level: owasp-check, input-validation, …
    docs/                    — docs-write, docs-review, …
    devops/                  — dockerfile, ci-pipeline, k8s, …
    reference/               — reference-docs, reference-help, reference-sourcecode,
                               reference-api, reference-changelog, reference-config,
                               reference-examples, reference-list
  python/ javascript/ go/    — language-specific skills
    analysis/                — code-review, check-bugs  (used by Reviewer)
    generation/              — generate-func, …         (used by Executor)
    refactoring/             — extract-func, …          (used by Refactorer)
    testing/                 — generate-test, …         (used by Executor, Reviewer, Refactorer)
    debugging/               — analyze-trace, …         (used by Debugger)
    performance/             — language-specific perf   (used by Performance)
  templates/                 — base templates for parallel skill families
                               (analyze-trace, detect-bugs, reference-base, generate-func, …)
config/
  tools/                     — one JSON definition per supported external tool
                               (validated by validate.sh: required fields, name matches filename)
docs/contracts/              — input/output schemas for each agent handoff
docs/severity-mappings.md    — severity levels + language-specific pattern tables
docs/tools-config.md         — tool definition schema + enable-tool usage
hooks/hooks.json             — hook configuration (JSON)
scripts/                     — install, scaffold, validate, release utilities
```

## Agent handoff contracts

Every agent produces a structured output block. The schema for each is in `docs/contracts/`.
Do not change the section headers in agent outputs — downstream agents parse them by name.

| Handoff | Contract file |
|---------|--------------|
| Language Router → Context | `docs/contracts/routing-block.md` |
| Context → Planner (or Executor if skipPlanner) | `docs/contracts/context-summary.md` |
| Planner → Executor | `docs/contracts/implementation-plan.md` |
| Executor → Reviewer (or done if skipReview) | `docs/contracts/execution-summary.md` |
| Reviewer → next | `docs/contracts/review-report.md` |
| Debugger → Executor (or User if BLOCKED) | `docs/contracts/debug-report.md` |
| Refactorer → done | `docs/contracts/refactoring-summary.md` |
| Performance → Executor (FIX_NOW) or User (MEASURE_FIRST) | `docs/contracts/performance-report.md` |

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
- `$ARGUMENTS` captures user-provided input; wrap it in a `## User question` section and add a fallback ("If no question is provided, ask the user…") so Claude handles empty invocations gracefully
- Keep prompts actionable: tell Claude what to do, what to output, what format to use
- If a skill is part of a parallel family (e.g. `analyze-trace` exists in py/js/go), set `template:` to the shared base in `skills/templates/` and keep only language-specific details in the skill body. `validate.sh` checks that the referenced template exists.
- All eight reference skills share a common tool-resolution preamble via `template: reference-base`. Do not duplicate Steps 1–3 in reference skill bodies — edit `skills/templates/reference-base.md` instead. The template also handles version pinning (`{"name": "redis", "version": "7.2"}`) and alias matching.

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
- Register new agents in the `agents` array in `.claude-plugin/plugin.json`

Scaffold: `./scripts/new-agent.sh <name>`

## Adding a new language

Use the scaffold script — it creates all 6 subcategories and registers paths in `plugin.json`:

```bash
./scripts/new-language.sh <language-name>
# Example: ./scripts/new-language.sh rust
```

Then fill in the generated placeholder SKILL.md files.

## Adding a new tool (reference skill family)

Tool definitions live in `config/tools/<name>.json`. All eight reference skills load these at
runtime — `reference-docs`, `reference-help`, `reference-sourcecode`, `reference-api`,
`reference-changelog`, `reference-config`, `reference-examples`, and `reference-list`.

```bash
# Add a new tool definition to the plugin
./scripts/add-tool.sh \
  --name grafana \
  --description "Metrics dashboarding and alerting platform" \
  --docs-url "https://grafana.com/docs/grafana/latest/" \
  --github grafana/grafana \
  --branch main \
  --examples "dashboard provisioning,alerting rules,data sources" \
  --api-url "https://grafana.com/docs/grafana/latest/developers/http_api/" \
  --aliases "grafana-oss" \
  --config-paths "conf/defaults.ini" \
  --related-repos "grafana/loki,grafana/tempo"
# → creates config/tools/grafana.json

# Enable tools in a project by adding to settings.json:
#   { "tools": ["grafana"] }
#   { "tools": [{"name": "redis", "version": "7.2"}] }   ← version-pinned source lookups

# Alternatively, copy the config into the project directory:
./scripts/enable-tool.sh grafana /path/to/project
```

Optional tool config fields:

| Field | Description |
|-------|-------------|
| `docs.api_url` | Dedicated API reference URL — used by `reference-api` |
| `config.paths` | Paths to default config files in the repo — used by `reference-config` |
| `aliases` | Short names users may use (e.g. `k8s`, `pg`) for tool selection |
| `github.related_repos` | Fallback repos for `reference-sourcecode` when primary yields nothing |

See `docs/tools-config.md` for the full schema and all bundled tool definitions.

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
#   - config/tools/*.json: valid JSON, required fields present, name matches filename stem
#   - routing block field names and NEXT value match between language-router.md and contract
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

Hooks are configured in `hooks/hooks.json`. Hook scripts live in `scripts/hooks/`
and must be executable. Two hooks are active:

- **Python** (`format-python.sh`): runs `ruff format` + `ruff check --fix` after any Write or Edit to a `.py`/`.pyi` file
- **JavaScript** (`format-js.sh`): runs after any Write or Edit to a `.js`/`.ts`/`.jsx`/`.tsx` file

When adding a new language, `./scripts/new-language.sh` creates a stub hook script at `scripts/hooks/format-<language>.sh` automatically.

## Statusline

`scripts/statusline-command.sh` is installed to `~/.claude/statusline-command.sh` by `install.sh` and wired into `~/.claude/settings.json` as a `type: command` statusline. `update.sh` syncs the script on each run.

The statusline reads Claude's JSON status from stdin and outputs:

```
~/Dev/uye/skills-plugin  main*  sonnet4.6  @executor  23%/88%/43%  12k/$0.45  9:40pm/May 1 2:59am
│                         │      │           │           │            │           │
bold cyan                 green  magenta     orange      pct colors   tok/cost    grey
```

Fields shown (each omitted independently if data is absent):

| Field | Color | Source |
|-------|-------|--------|
| Directory (tilde-prefixed) | bold cyan | `.workspace.current_dir` |
| Git branch + `*` dirty flag | green / yellow `*` | `git symbolic-ref` |
| Model (shortened: `sonnet4.6`) | magenta | `.model.id` |
| Agent name (`@name`) | orange | `.agent.name` (absent unless `--agent` is set) |
| Context / 5-hour / 7-day usage % | green→yellow→orange→red | `.context_window`, `.rate_limits` |
| Total tokens / session cost | green→yellow→orange→red | `.context_window`, `.cost` |
| Rate-limit reset times: `H:MMam/DD-MMT H:MMam` | grey | `.rate_limits.*.resets_at` (Unix epoch) |

**Color thresholds:**
- Percentages: `< 40%` green · `40–74%` yellow · `75–94%` orange · `≥ 95%` red
- Tokens: `≤ 50k` green · `50–100k` yellow · `100–200k` orange · `> 200k` red
- Cost: `≤ $5` green · `$5–$10` yellow · `$10–$20` orange · `> $20` red

Orange uses the 256-color escape `\033[38;5;208m` and degrades gracefully on 8-color terminals.

## Releasing

```bash
./scripts/release.sh <version>
# Example: ./scripts/release.sh 2.1.0
# Updates plugin.json version, prepends CHANGELOG entry, shows next steps
```

## Conventions

- Skill names: `kebab-case`, prefixed with language name (`py-`, `js-`, `go-` for the bundled languages; full name for new ones, e.g. `rust-`, `kotlin-`) or unprefixed for common
- Agent names: `kebab-case`, role-based (not language-based)
- Script names: `kebab-case` verbs (`new-skill.sh`, `validate.sh`, `list-skills.sh`)
- All scripts must start with `set -euo pipefail` and include a usage comment
- Do not hardcode absolute paths in scripts — use `PLUGIN_DIR` derived from `${BASH_SOURCE[0]}`
