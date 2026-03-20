# Template: reference-base
# Used by: reference-docs, reference-help, reference-sourcecode
#
# Provides the shared tool resolution preamble (Steps 1–3).
# Each skill declares `template: reference-base` and adds its own Step 4+.

## Step 1 — Resolve active tools

Read `settings.json` in the current project directory. Find the `tools` array.
If the array is empty or missing, reply:
"No tools are enabled. Add a tool name to the `tools` array in `settings.json`."

## Step 2 — Load tool config

For each tool name in the `tools` array, load its config by checking these paths in order:

1. `<project-root>/.claude-plugin/tools/<tool-name>.json` — project-local override
2. `<plugin-root>/config/tools/<tool-name>.json` — plugin default

The plugin root is the directory containing `skills/common/reference/` — navigate up from
this file's location until you find the `config/tools/` directory.

If the config file is found in neither location, report:
"Tool '<name>' is not defined. Run `./scripts/add-tool.sh` to register it, or copy the
config into `.claude-plugin/tools/`."

## Step 3 — Select relevant tool

If only one tool is active, use it.

If multiple tools are active, select the one whose `description` and `examples` fields
best match the user's question. If two or more tools are equally plausible, do not guess —
ask the user: "Both `<tool-a>` and `<tool-b>` seem relevant. Which tool are you asking about?"
