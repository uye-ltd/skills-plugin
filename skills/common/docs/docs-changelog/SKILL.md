---
name: docs-changelog
description: Generate or update a CHANGELOG entry based on recent commits, diffs, or a description of changes.
language: common
used-by: standalone
---

Generate a CHANGELOG entry following the Keep a Changelog format (https://keepachangelog.com).

Steps:
1. Identify the version and release date (ask if not provided)
2. Categorise changes under: Added, Changed, Deprecated, Removed, Fixed, Security
3. Write entries from a user perspective — what changed and why it matters, not implementation details
4. Keep entries concise (one line each where possible)

If given raw commit messages or a diff, extract meaningful changes and discard noise (typos, refactors with no user impact, merge commits).

$ARGUMENTS
