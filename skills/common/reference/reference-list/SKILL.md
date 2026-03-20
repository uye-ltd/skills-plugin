---
name: reference-list
description: >
  List all tools currently enabled in the project's settings.json `tools` array, with
  their descriptions and available reference skills. Use when the user asks which tools
  are configured, what tools are available, or wants an overview of what reference skills
  can answer. Takes no arguments. Dormant when `tools` is empty.
language: common
used-by: standalone
template: reference-base
disable-model-invocation: false
---

# Reference List Skill

List all enabled tools and what the reference skills can do with them.

<!-- Steps 1–3: tool resolution — see skills/templates/reference-base.md -->
<!-- Note: Step 3 (select relevant tool) is skipped — this skill lists ALL enabled tools. -->

## Step 4 — Build the tool list

For each tool loaded in Step 2, collect:
- `name`
- `description`
- `aliases` (if present)
- `docs.url`
- `docs.api_url` (if present)
- `github.org/github.repo`

## Step 5 — Output

Print a summary table followed by capability notes:

```
Enabled tools in this project:

┌─────────────────┬──────────────────────────────────────────────────────────┐
│ Tool            │ Description                                              │
├─────────────────┼──────────────────────────────────────────────────────────┤
│ <name>          │ <description>                                            │
│  aliases: ...   │                                                          │
└─────────────────┴──────────────────────────────────────────────────────────┘

Available reference skills for each tool:
  reference-docs        — Official documentation lookup
  reference-api         — API endpoint reference       [if docs.api_url present]
  reference-help        — GitHub issues and community answers
  reference-sourcecode  — Source code inspection
  reference-changelog   — Release notes and version history
  reference-config      — Default configuration files
  reference-examples    — Usage examples and sample configs
```

If only one tool is enabled, skip the table and present a single-tool summary inline.
If no tools are enabled, reply: "No tools are enabled. Add a tool name to the `tools`
array in `settings.json` and run `reference-list` again."
