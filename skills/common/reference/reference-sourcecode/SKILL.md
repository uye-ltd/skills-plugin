---
name: reference-sourcecode
description: >
  Inspect the source code of any tool enabled in the project's settings.json
  `tools` array via the GitHub API. Use when understanding internal behaviour,
  tracing request handling, investigating data models, or explaining how a feature
  works at the implementation level. Do NOT use for basic configuration or
  installation questions. Dormant when `tools` is empty.
language: common
used-by: standalone
template: reference-base
---

# Reference Sourcecode Skill

Inspect source code for the active tool directly via the GitHub API.

<!-- Steps 1–3: tool resolution — see skills/templates/reference-base.md -->

## Step 4 — Navigate source code

Using the selected tool's `github.org`, `github.repo`, and `github.branch` fields.
Always include `?ref=<branch>` on contents API calls to ensure the correct branch is used.

1. Discover repository structure:
   ```
   WebFetch https://api.github.com/repos/<org>/<repo>/contents/?ref=<branch>
   ```

2. Navigate into relevant directories:
   ```
   WebFetch https://api.github.com/repos/<org>/<repo>/contents/<directory>?ref=<branch>
   ```

3. Search the repository for relevant keywords if the file location is unknown:
   ```
   WebFetch https://api.github.com/search/code?q=KEYWORD+repo:<org>/<repo>
   ```

4. Fetch a specific file using the confirmed path and branch:
   ```
   WebFetch https://raw.githubusercontent.com/<org>/<repo>/<branch>/<path-to-file>
   ```

## Investigation strategy

1. Locate relevant code via repository listing or code search
2. Fetch the file(s) containing the implementation
3. Trace logic across layers: handlers → services → models → persistence
4. Explain how the implementation works

## Expected output

- Reference specific files and line ranges
- Explain how the code works
- Include function/method names and key logic
- Provide links to the source files on GitHub

## User question

$ARGUMENTS

If no question is provided, ask the user what they want to know about the tool.
