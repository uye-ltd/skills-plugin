#!/usr/bin/env bash
# new-category.sh — Scaffold a new common category (non-language).
#
# Usage:
#   ./scripts/new-category.sh <category-name> [skill1 skill2 ...]
#
# Examples:
#   ./scripts/new-category.sh accessibility contrast-check keyboard-nav screen-reader
#   ./scripts/new-category.sh testing-strategy mutation-testing property-based-testing
#
# If no skills are provided, creates an empty category directory only.
# Add skills later with: ./scripts/new-skill.sh common <category> <skill-name>

set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CATEGORY="${1:-}"

if [ -z "$CATEGORY" ]; then
  echo "Usage: $0 <category-name> [skill1 skill2 ...]"
  echo ""
  echo "Examples:"
  echo "  $0 accessibility contrast-check keyboard-nav"
  echo "  $0 testing-strategy mutation-testing"
  exit 1
fi

shift
SKILLS=("$@")

CATEGORY_DIR="$PLUGIN_DIR/skills/common/$CATEGORY"
PLUGIN_JSON="$PLUGIN_DIR/.claude-plugin/plugin.json"
CATEGORY_PATH="./skills/common/$CATEGORY"

if [ -d "$CATEGORY_DIR" ]; then
  echo "Error: category '$CATEGORY' already exists at $CATEGORY_DIR" >&2
  exit 1
fi

mkdir -p "$CATEGORY_DIR"
echo "Created: skills/common/$CATEGORY/"

# Create skill stubs
for skill in "${SKILLS[@]}"; do
  skill_dir="$CATEGORY_DIR/$skill"
  mkdir -p "$skill_dir"
  cat > "$skill_dir/SKILL.md" << EOF
---
name: $skill
description: TODO: describe what this skill does and when Claude should invoke it.
language: common
used-by: standalone
# disable-model-invocation: false
---

TODO: Write the skill instructions here.

\$ARGUMENTS
EOF
  echo "  Created: skills/common/$CATEGORY/$skill/SKILL.md"
done

# Register in plugin.json
python3 - "$PLUGIN_JSON" "$CATEGORY_PATH" << 'PYEOF'
import sys, json

plugin_json_path = sys.argv[1]
new_path = sys.argv[2]

with open(plugin_json_path) as f:
    data = json.load(f)

if new_path not in data.get("skills", []):
    data["skills"] = data.get("skills", []) + [new_path]
    with open(plugin_json_path, "w") as f:
        json.dump(data, f, indent=2)
        f.write("\n")
    print(f"Registered '{new_path}' in plugin.json")
else:
    print(f"'{new_path}' already in plugin.json")
PYEOF

echo ""
if [ ${#SKILLS[@]} -gt 0 ]; then
  echo "Done. Fill in the SKILL.md files in skills/common/$CATEGORY/"
else
  echo "Done. Add skills with: ./scripts/new-skill.sh common $CATEGORY <skill-name>"
fi
echo "Test with: claude --plugin-dir $PLUGIN_DIR"
