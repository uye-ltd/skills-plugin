#!/usr/bin/env bash
# new-skill.sh — Scaffold a new skill from a template.
#
# Usage:
#   ./scripts/new-skill.sh <language> <subcategory> <skill-name>
#   ./scripts/new-skill.sh common <subcategory> <skill-name>
#
# Examples:
#   ./scripts/new-skill.sh python refactoring inline-const
#   ./scripts/new-skill.sh javascript debugging detect-memory-leak
#   ./scripts/new-skill.sh common analysis detect-dead-code
#
# After creating a new language/subcategory combination, add the path to
# .claude-plugin/plugin.json "skills" array.

set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LANGUAGE="${1:-}"
SUBCATEGORY="${2:-}"
SKILL_NAME="${3:-}"

if [ -z "$LANGUAGE" ] || [ -z "$SUBCATEGORY" ] || [ -z "$SKILL_NAME" ]; then
  echo "Usage: $0 <language|common> <subcategory> <skill-name>"
  echo ""
  echo "Examples:"
  echo "  $0 python refactoring inline-const"
  echo "  $0 javascript debugging detect-memory-leak"
  echo "  $0 common analysis detect-dead-code"
  exit 1
fi

SKILL_DIR="$PLUGIN_DIR/skills/$LANGUAGE/$SUBCATEGORY/$SKILL_NAME"
PLUGIN_JSON="$PLUGIN_DIR/.claude-plugin/plugin.json"
CATEGORY_PATH="./skills/$LANGUAGE/$SUBCATEGORY"

if [ -d "$SKILL_DIR" ]; then
  echo "Error: skill '$SKILL_NAME' already exists at $SKILL_DIR" >&2
  exit 1
fi

mkdir -p "$SKILL_DIR"

cat > "$SKILL_DIR/SKILL.md" << EOF
---
name: ${LANGUAGE}-${SKILL_NAME}
description: TODO: describe what this skill does and when Claude should invoke it. Be specific — used by the pipeline agents to select the right skill.
# disable-model-invocation: false  # optional — set true to prevent automatic invocation
---

TODO: Write the skill instructions here.
Be specific about:
- What Claude should do step by step
- What the output format should be
- Any conventions or constraints (language version, style guide, etc.)

\$ARGUMENTS
EOF

echo "Created: $SKILL_DIR/SKILL.md"

# Check if this subcategory path is already in plugin.json
if grep -q "\"$CATEGORY_PATH\"" "$PLUGIN_JSON"; then
  echo "Subcategory '$CATEGORY_PATH' is already registered in plugin.json."
else
  echo ""
  echo "New subcategory detected: '$CATEGORY_PATH'"
  echo "Add it to the 'skills' array in .claude-plugin/plugin.json:"
  echo ""
  echo "  \"$CATEGORY_PATH\""
  echo ""
fi

echo ""
echo "Next steps:"
echo "  1. Edit $SKILL_DIR/SKILL.md"
echo "  2. Test with: claude --plugin-dir $PLUGIN_DIR"
echo "  3. Invoke as: /uye:${LANGUAGE}-${SKILL_NAME}"
