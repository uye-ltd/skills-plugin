---
name: reference-help
description: >
  Search GitHub issues and discussions for any tool enabled in the project's
  settings.json `tools` array. Use for debugging unusual behaviour, known
  limitations, undocumented quirks, or questions that may have been answered by
  maintainers or the community. Do NOT use for basic how-to questions covered by
  official docs. Dormant when `tools` is empty.
language: common
used-by: standalone
template: reference-base
---

# Reference Help Skill

Search GitHub issues and discussions for the active tool to find existing answers,
workarounds, or maintainer explanations.

<!-- Steps 1–3: tool resolution — see skills/templates/reference-base.md -->

## Step 4 — Search GitHub issues, discussions, and wiki

Using the selected tool's `github.org` and `github.repo` fields:

1. Search issues via the GitHub REST search API — replace `KEYWORD` with 2–3 terms
   from the user's question:
   ```
   WebFetch https://api.github.com/search/issues?q=KEYWORD+repo:<org>/<repo>
   ```

2. Search discussions — use `WebSearch` since GitHub Discussions has no REST API:
   ```
   WebSearch site:github.com/<org>/<repo>/discussions KEYWORD
   ```
   Follow the most relevant result URLs to read the discussion threads.

3. Fetch the full thread for the most relevant issues:
   ```
   WebFetch https://api.github.com/repos/<org>/<repo>/issues/<number>
   WebFetch https://api.github.com/repos/<org>/<repo>/issues/<number>/comments
   ```

4. Check the GitHub wiki for supplementary guides or known-issue pages:
   ```
   WebFetch https://github.com/<org>/<repo>/wiki
   ```
   If the wiki index lists pages relevant to the user's question, fetch those pages:
   ```
   WebFetch https://github.com/<org>/<repo>/wiki/<Page-Name>
   ```
   Skip this step silently if the repo has no wiki (404 or empty response).

## Investigation strategy

1. Search issues and discussions with 2–3 relevant keywords
2. Prioritise threads with maintainer responses or a confirmed solution
3. Read the full thread to extract context, workarounds, and resolution status
4. Check the wiki for relevant guides or known-issue pages

## Expected output

- Reference the issue or discussion number and title
- Summarise the maintainer or community explanation
- Include links to the relevant threads
- Note any workarounds or recommended solutions

## User question

$ARGUMENTS

If no question is provided, ask the user what they want to know about the tool.
