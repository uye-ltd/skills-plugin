#!/usr/bin/env bash
# enable-tool.sh — Copy a tool config into a project's .claude-plugin/tools/ directory.
#
# Use this when the consuming project cannot reference the plugin path at runtime
# (e.g. the project is deployed separately). The reference skills check
# .claude-plugin/tools/ first, then fall back to the plugin's config/tools/.
#
# Usage:
#   ./scripts/enable-tool.sh <tool-name> <project-path>
#
# Examples:
#   ./scripts/enable-tool.sh filebrowser /home/user/my-project
#   ./scripts/enable-tool.sh traefik ../infra-repo

set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

TOOL_NAME="${1:-}"
PROJECT_PATH="${2:-}"

if [ -z "$TOOL_NAME" ] || [ -z "$PROJECT_PATH" ]; then
  echo "Usage: $0 <tool-name> <project-path>"
  echo ""
  echo "Examples:"
  echo "  $0 filebrowser /home/user/my-project"
  echo "  $0 traefik ../infra-repo"
  exit 1
fi

SOURCE="$PLUGIN_DIR/config/tools/$TOOL_NAME.json"

if [ ! -f "$SOURCE" ]; then
  echo "Error: tool '$TOOL_NAME' not found at config/tools/$TOOL_NAME.json" >&2
  echo ""
  echo "Available tools:"
  for f in "$PLUGIN_DIR/config/tools/"*.json; do
    [ -f "$f" ] && echo "  $(basename "$f" .json)"
  done
  exit 1
fi

PROJECT_ABS="$(cd "$PROJECT_PATH" && pwd)"
DEST_DIR="$PROJECT_ABS/.claude-plugin/tools"
mkdir -p "$DEST_DIR"

cp "$SOURCE" "$DEST_DIR/$TOOL_NAME.json"

echo "Copied config/tools/$TOOL_NAME.json → $PROJECT_ABS/.claude-plugin/tools/$TOOL_NAME.json"
echo ""
echo "Ensure settings.json in '$PROJECT_ABS' includes:"
echo "  { \"tools\": [\"$TOOL_NAME\"] }"
