#!/usr/bin/env bash
# install.sh — Install the uye plugin at project scope in a target repository.
#
# Usage:
#   ./scripts/install.sh                  # install into the current directory
#   ./scripts/install.sh /path/to/repo    # install into a specific repo
#
# This adds the plugin to the target repo's .claude/settings.json (project scope),
# so the config is committed and shared with the whole team.

set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${1:-$(pwd)}"

if [ ! -d "$TARGET" ]; then
  echo "Error: target directory '$TARGET' does not exist." >&2
  exit 1
fi

if [ ! -d "$TARGET/.git" ]; then
  echo "Warning: '$TARGET' does not appear to be a git repository."
  read -r -p "Continue anyway? [y/N] " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
  fi
fi

echo "Installing uye plugin..."
echo "  Plugin:  $PLUGIN_DIR"
echo "  Target:  $TARGET"
echo "  Scope:   project"
echo ""

cd "$TARGET"
claude plugin install "$PLUGIN_DIR" --scope project

echo ""
echo "Done. The plugin has been added to $TARGET/.claude/settings.json"
echo "Commit that file to share the plugin with your team:"
echo ""
echo "  git add .claude/settings.json && git commit -m 'chore: add uye claude plugin'"
