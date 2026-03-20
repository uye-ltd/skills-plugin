---
name: reference-changelog
description: >
  Fetch release notes, changelogs, or version history for any tool enabled in the
  project's settings.json `tools` array. Use when the user asks what changed between
  versions, what broke in an upgrade, when a feature was added, or what a release
  contains. Do NOT use for general how-to questions — use reference-docs instead.
  Dormant when `tools` is empty.
language: common
used-by: standalone
template: reference-base
---

# Reference Changelog Skill

Fetch and summarise release notes or changelog entries for the active tool.

<!-- Steps 1–3: tool resolution — see skills/templates/reference-base.md -->

## Step 4 — Fetch changelog or release notes

Using the selected tool's `github.org` and `github.repo` fields, try these sources in order:

### 4a — GitHub Releases API
```
WebFetch https://api.github.com/repos/<org>/<repo>/releases?per_page=20
```
- If the user asked about a specific version, find the matching release by `tag_name`.
- If the user asked "what changed recently", use the latest 3–5 releases.
- For version range queries ("what changed from 7.2 to 7.4"), collect all releases between
  those tags and summarise them together.

### 4b — CHANGELOG file fallback
If the GitHub Releases API returns no releases or releases without meaningful body text, fetch
the CHANGELOG directly from the repository:
```
WebFetch https://raw.githubusercontent.com/<org>/<repo>/<branch>/CHANGELOG.md
WebFetch https://raw.githubusercontent.com/<org>/<repo>/<branch>/CHANGELOG
WebFetch https://raw.githubusercontent.com/<org>/<repo>/<branch>/HISTORY.md
```
Try each path in order and stop at the first successful fetch.

### 4c — Releases page fallback
If neither the API nor the raw file yields content, fetch the HTML releases page:
```
WebFetch https://github.com/<org>/<repo>/releases
```

## Step 5 — Answer

Summarise the relevant changelog content:

- **Version header**: State the version and release date clearly.
- **Breaking changes**: Call these out first in a dedicated section if present.
- **New features**: Bullet list.
- **Bug fixes**: Bullet list — highlight any that match the user's context.
- **Deprecations / removals**: Note if present.
- **Source link**: Include a direct link to the GitHub release or CHANGELOG section.

If the user asked about a specific version that was not found, say so and list the nearest
available versions.

## User question

$ARGUMENTS

If no question is provided, ask the user which version or version range they want to know about.
