---
name: reference-config
description: >
  Locate and explain the default or reference configuration file for any tool enabled in
  the project's settings.json `tools` array. Use when the user asks about default settings,
  config file structure, available options, or what a config directive does. Relies on
  `config.paths` in the tool definition when present; falls back to heuristic search.
  Dormant when `tools` is empty.
language: common
used-by: standalone
template: reference-base
---

# Reference Config Skill

Fetch and explain a tool's default or reference configuration file from its source repository.

<!-- Steps 1–3: tool resolution — see skills/templates/reference-base.md -->

## Step 4 — Locate the config file

Using the selected tool's `github.org`, `github.repo`, and `github.branch`:

### 4a — Use known paths from tool config
If the tool definition contains a `config.paths` array, try each path in order:
```
WebFetch https://raw.githubusercontent.com/<org>/<repo>/<branch>/<path>
```
Stop at the first successful fetch (HTTP 200 with non-empty content).

### 4b — Heuristic search
If `config.paths` is absent or all paths fail, search for common config file names:
```
WebFetch https://api.github.com/search/code?q=repo:<org>/<repo>+filename:*.conf+filename:*.ini+filename:*.yaml+filename:*.toml
```
Filter results to files in the root or a `conf/`, `config/`, `etc/`, or `examples/`
directory. Prefer files with "default", "sample", or "reference" in the name.

If the code search returns candidates, fetch the most likely one:
```
WebFetch https://raw.githubusercontent.com/<org>/<repo>/<branch>/<path>
```

## Step 5 — Answer

Present the config file content and answer the user's question:

- If the user asked about a specific directive or section, extract and explain that part.
- If the user asked for a general overview, summarise the major sections and their purpose.
- Quote the relevant lines directly from the file.
- Include the full path of the config file within the repository.
- Provide a link to the raw file on GitHub.

Note any directives that are commented out (disabled by default) vs active defaults.

## User question

$ARGUMENTS

If no question is provided, ask the user what they want to know about the tool's configuration.
