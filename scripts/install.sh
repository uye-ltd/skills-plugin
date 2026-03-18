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
echo ""

# Step 1 — Register the plugin dir as a user-scoped marketplace (once per machine)
echo "Registering plugin as marketplace (user scope)..."
claude plugin marketplace add "$PLUGIN_DIR" --scope user

# Step 2 — Install the plugin at project scope in the target repo
echo "Installing uye plugin at project scope in $TARGET..."
cd "$TARGET"
claude plugin install uye --scope project

echo ""
echo "Done. Two things happened:"
echo "  1. $PLUGIN_DIR registered as a marketplace in your user config (~/.claude/)"
echo "     Re-running install.sh is safe — marketplace registration is idempotent."
echo "  2. The 'uye' plugin installed at project scope in $TARGET/.claude/settings.json"
echo ""
echo "Commit the settings file to share the plugin with your team:"
echo ""
echo "  git add .claude/settings.json && git commit -m 'chore: add uye claude plugin'"
echo ""
echo "Note: each developer needs to run install.sh once (or any install) to register"
echo "the marketplace on their machine before the plugin activates for them."
