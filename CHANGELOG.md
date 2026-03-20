## [0.3.0] - 2026-03-20

### Added
- `pipeline.maxIterations` setting (default: `3`) — Executor↔Reviewer loop now has an explicit upper bound; Reviewer emits `BLOCKED` when limit is reached and surfaces all unresolved issues directly to the user
- `pipeline.maxDebugCycles` setting (default: `2`) — Reviewer tracks how many times it has issued `DEBUG` and emits `BLOCKED` instead of re-escalating when the limit is hit, preventing infinite debug loops
- `context.maxFiles` setting (default: `20`) — Context agent now respects a file-read limit; files over the limit are listed in a `Files noted but not read` section rather than silently omitted
- `BLOCKED` output state for Reviewer (max iterations or max debug cycles exceeded) and Debugger (root cause cannot be determined) — both surface a structured report to the user instead of looping or guessing
- `PIPELINE` field in routing block — carries `skipPlanner`, `skipReview`, `maxIterations`, `maxDebugCycles`, and `contextMaxFiles` to all downstream agents, making all pipeline flags functional
- `agents` array in `.claude-plugin/plugin.json` — manifest is now self-describing; enables future tooling such as `validate.sh` agent path checks
- `docs/severity-mappings.md` — single source of truth for all severity levels and language-specific patterns; referenced by `reviewer.md` and `review-report.md`
- Routing block consistency check in `validate.sh` (section 8) — cross-checks field names, `NEXT` value, PIPELINE presence, and context precondition alignment
- `Iteration: N` field in Execution Summary — Reviewer reads this to enforce `maxIterations`; Executor increments it on each round trip
- `Attempt history` section in Review Report (required on ITERATE) — summarises what was tried and why it failed in each prior round so Executor does not repeat the same approach
- `Changes` section in Execution Summary — before/after diff per modified file; Reviewer reviews diffs directly instead of re-reading full files each round
- Security gate in Reviewer — `secrets-scan`, `owasp-check`, and `input-validation` now run on every review pass; results go in a required `Security findings` section (never silently absent)
- `Performance Fix Request` block in performance-report contract — structured handoff format for `FIX_NOW` decisions; Executor receives and applies it like an Implementation Plan, then routes to Reviewer
- `verify-tests` skill added to Refactorer's skill set for all three languages — invoked after each refactoring step to confirm the suite passes before proceeding
- Full multi-language pipeline specification — Context, Planner, Executor, Reviewer, and all five contracts now define the protocol for multi-language tasks (per-language labeled sections, cross-language dependency section, strictest-verdict-wins rule for Reviewer)
- Language pin mismatch warning in Language Router — emits a visible warning when `settings.json` `language` pin does not match the file extensions in the task, without blocking

### Changed
- Language Router now reads `settings.json` before detection; `language` pin is honoured as rule #1 (highest priority, above explicit user instruction)
- `EXECUTOR_SKILLS` now includes `<language>/testing/` for all three languages — test-generation skills (`py-generate-test`, `js-generate-test`, `go-generate-test`, etc.) are now reachable from Executor
- Multi-language routing blocks now emit `COMMON_SKILLS` and `PIPELINE` once after all per-language blocks instead of repeating them
- Reviewer Refactorer invocation now has explicit criteria: invoke after PASS if `detect-code-smells` or `analyze-complexity` flagged anything; "Done — no refactoring needed" only when both are clean
- Severity mappings moved out of `reviewer.md` into `docs/severity-mappings.md`; both `reviewer.md` and `review-report.md` reference the shared document
- Executor and Planner no longer independently re-detect language versions; both consume version info from the Context Summary (Context agent already reads `go.mod`, `package.json`, `.nvmrc`, `pyproject.toml`)
- Context agent checks `skipPlanner` PIPELINE flag and hands off to Executor directly when set
- Executor checks `skipReview` PIPELINE flag and marks complete without invoking Reviewer when set
- Performance agent `FIX_NOW` now routes to Executor via a structured `Performance Fix Request` block; `MEASURE_FIRST` explicitly does not route to Executor
- Refactorer test-pass checklist item is now enforced via `verify-tests` skill invocation after each step, not just a self-reported checkbox
- `settings.json` converted from JSONC (invalid JSON with `//` comments) to valid JSON; documentation comments moved to `CLAUDE.md`
- `common/security/` skills (`secrets-scan`, `owasp-check`, `input-validation`) promoted from standalone-only to active pipeline participants via the Reviewer security gate

### Fixed
- Routing block field names corrected from space-separated (`EXECUTOR SKILLS`) to underscore-separated (`EXECUTOR_SKILLS`) — the space variant caused Context agent precondition checks to always fail silently
- `NEXT` value corrected from `context-agent` to `context` — aligns with contract definition and Context agent `NEXT = "context"` precondition check
- Routing block contract invariant incorrectly stated "all skill paths must exist in `plugin.json`"; language-specific skills are routed dynamically and are not in `plugin.json`
- `pipeline.skipPlanner` and `pipeline.skipReview` were documented in `settings.json` and `CLAUDE.md` but never read by any agent — now wired through the PIPELINE routing block field
- Duplicate "explain root cause" rule removed from `debugger.md` (was stated on both line 46 and line 51)
- Performance agent `FIX_NOW` had no implementation path — the contract said "Consumed by: Executor" but no handoff format or routing existed; now fully defined
- Debug cycle (DEBUG→Executor→Reviewer) had no iteration guard — only the Executor↔Reviewer loop had `maxIterations`; debug cycle now guarded by `maxDebugCycles`
- Multi-language tasks were documented in the routing block but undefined at every subsequent pipeline stage — Context, Planner, Executor, Reviewer contracts all lacked multi-language handling rules
- Context agent had no file-read limit — large codebases could exhaust the context window before planning began; `contextMaxFiles` now provides a configurable ceiling
- Refactorer `verify-tests` checklist item was aspirational — no skill was assigned or invoked; now enforced via the `verify-tests` skill after each operation
- Security skills (`secrets-scan`, `owasp-check`, `input-validation`) were registered in `plugin.json` but never invoked by any pipeline agent; code could pass full review without a security check
- `new-language.sh` truncated language name to 2 characters when naming scaffolded skills (`ru-code-review` instead of `rust-code-review`); now uses the full language name as prefix
- `detect-code-smells` typo: "functions ohover 50 lines" corrected to "functions over 50 lines"
- `detect-code-smells` severity labels were `high / medium / low`, mismatched with the pipeline standard `critical / major / minor / nit` from `docs/severity-mappings.md`; Reviewer had to mentally translate before the ITERATE/DEBUG decision chain
- `detect-code-smells` missing `## User question` section and `$ARGUMENTS` fallback, violating the skill convention in CLAUDE.md
- `needs-debug` column referenced in the Reviewer decision rule ("Any issue flagged `needs-debug: true` → DEBUG") but absent from the Issues table in `docs/contracts/review-report.md` and `agents/reviewer.md`; the rule could never be triggered through the table
- `docs/contracts/performance-report.md` was the only contract without a `NEXT` field; routing from the Performance agent was implicit rather than declared
- Placeholder email `placeholder@example.com` in `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`; replaced with `org@uye.rocks`

### Commits since v0.2.1
- 80b9f67 feat: reference skills major update
- ed53820 feat: v0.2.1
- eb6bae8 feat: reference skills
- 4a5d0b6 refactor: major refactor
- 5d33ba8 refactor: major refactor
- bb3fff5 refactor: major refactor
- b73ea4e feat: common skills and agents clenup
- 52a840a feat: styleguide for python, go, js
- e7ca22a feat: initial structure
- 4a42a34 Initial commit

## [0.2.1] - 2026-03-20

### Added
- Reference skills family: `reference-docs`, `reference-help`, `reference-sourcecode`, `reference-api`, `reference-changelog`, `reference-config`, `reference-examples`, `reference-list` — all eight load tool definitions from `config/tools/` at runtime
- `config/tools/` directory with JSON tool definitions (postgres, redis, and others); validated by `validate.sh`
- `skills/templates/reference-base.md` — shared preamble for all eight reference skills covering tool resolution, version pinning, and alias matching
- `tools` setting in `settings.json` — enables reference skills per-project with optional version pinning (e.g. `[{"name": "redis", "version": "7.2"}]`)

### Commits since v0.2.0
- eb6bae8 feat: reference skills
- 4a5d0b6 refactor: major refactor
- 5d33ba8 refactor: major refactor
- bb3fff5 refactor: major refactor
- b73ea4e feat: common skills and agents clenup
- 52a840a feat: styleguide for python, go, js
- e7ca22a feat: initial structure
- 4a42a34 Initial commit

## [0.2.0] - 2026-03-18

### Added
- Skills for idiomatic Python / Go / TS

### Commits since 
- 5d33ba8 refactor: major refactor
- bb3fff5 refactor: major refactor
- b73ea4e feat: common skills and agents clenup
- 52a840a feat: styleguide for python, go, js
- e7ca22a feat: initial structure
- 4a42a34 Initial commit

# Changelog

All notable changes to this plugin will be documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

Versioning follows [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.1.0] - 2026-03-14

### Added
- Initial plugin scaffold with namespace `uye`
- Skills: `docs` category (docs-write, docs-review, docs-changelog, docs-readme, docs-api)
- Skills: `python` category (py-review, py-tests, py-refactor, py-debug, py-types)
- Skills: `go` category (go-review, go-tests, go-refactor, go-interfaces, go-debug)
- Skills: `js` category (js-review, js-tests, js-refactor, js-component, js-debug)
- Skills: `devops` category (dockerfile, ci-pipeline, k8s, debug-pipeline, security-scan)
- Agents: docs-reviewer, python-expert, go-expert, js-expert, devops-engineer
- Hook configuration template with all 14 events commented out
- Install script for deploying to org repos at project scope
- Scaffold scripts for new skills and agents
