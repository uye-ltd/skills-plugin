---
name: reference-examples
description: >
  Find real-world usage examples, sample configurations, or demo setups for any tool
  enabled in the project's settings.json `tools` array. Use when the user wants a
  working example, starter config, or to see how a feature is used in practice.
  Complements reference-docs (conceptual) and reference-sourcecode (internals) with
  concrete, copy-paste-ready patterns. Dormant when `tools` is empty.
language: common
used-by: standalone
template: reference-base
---

# Reference Examples Skill

Find and present practical usage examples for the active tool from its source repository.

<!-- Steps 1–3: tool resolution — see skills/templates/reference-base.md -->

## Step 4 — Locate examples

Using the selected tool's `github.org`, `github.repo`, and `github.branch`:

### 4a — Explore standard example directories
Check common example/sample locations in order:
```
WebFetch https://api.github.com/repos/<org>/<repo>/contents/examples?ref=<branch>
WebFetch https://api.github.com/repos/<org>/<repo>/contents/samples?ref=<branch>
WebFetch https://api.github.com/repos/<org>/<repo>/contents/example?ref=<branch>
WebFetch https://api.github.com/repos/<org>/<repo>/contents/demo?ref=<branch>
```
Stop at the first directory listing that returns results.

### 4b — Search for example files
If no standard directory exists, search for example files matching the user's question:
```
WebFetch https://api.github.com/search/code?q=<keyword>+repo:<org>/<repo>+path:example
WebFetch https://api.github.com/search/code?q=<keyword>+repo:<org>/<repo>+extension:yaml+extension:json+extension:conf
```

### 4c — Check docker-compose and quickstart files
Look for commonly used starter files at the repo root:
```
WebFetch https://raw.githubusercontent.com/<org>/<repo>/<branch>/docker-compose.yml
WebFetch https://raw.githubusercontent.com/<org>/<repo>/<branch>/docker-compose.yaml
WebFetch https://raw.githubusercontent.com/<org>/<repo>/<branch>/quickstart/docker-compose.yml
```

## Step 5 — Fetch and present

Once relevant example files are identified, fetch their content:
```
WebFetch https://raw.githubusercontent.com/<org>/<repo>/<branch>/<path>
```

Present the example:
- Quote the relevant section of the file directly.
- Annotate key lines with brief inline comments explaining what each does.
- If the example requires modification for the user's specific case, say so and suggest changes.
- Provide a link to the full file on GitHub.
- If multiple examples are relevant, present the simplest first.

## User question

$ARGUMENTS

If no question is provided, ask the user what they want an example of.
