#!/usr/bin/env bash
# new-language.sh — Scaffold a complete new language with all standard subcategories.
#
# Usage:
#   ./scripts/new-language.sh <language-name>
#
# Example:
#   ./scripts/new-language.sh rust
#
# Creates:
#   skills/<language>/{analysis,generation,refactoring,testing,debugging,performance}/
#   A placeholder SKILL.md in each subcategory
#   Registers all paths in .claude-plugin/plugin.json

set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LANGUAGE="${1:-}"

if [ -z "$LANGUAGE" ]; then
  echo "Usage: $0 <language-name>"
  echo "Example: $0 rust"
  exit 1
fi

LANG_DIR="$PLUGIN_DIR/skills/$LANGUAGE"
PLUGIN_JSON="$PLUGIN_DIR/.claude-plugin/plugin.json"

if [ -d "$LANG_DIR" ]; then
  echo "Error: language '$LANGUAGE' already exists at $LANG_DIR" >&2
  exit 1
fi

SUBCATEGORIES=(analysis generation refactoring testing debugging performance)

# Skill stubs to create in each subcategory
declare -A SKILL_STUBS=(
  [analysis]="code-review check-bugs"
  [generation]="generate-func update-imports"
  [refactoring]="extract-func remove-dup rename-sym"
  [testing]="generate-test verify-tests"
  [debugging]="analyze-trace detect-bugs"
  [performance]="profile-hotspot"
)

# Which agent uses each subcategory
declare -A USED_BY=(
  [analysis]="reviewer"
  [generation]="executor"
  [refactoring]="refactorer"
  [testing]="executor,reviewer"
  [debugging]="debugger"
  [performance]="performance"
)

echo "Creating language: $LANGUAGE"
echo ""

for sub in "${SUBCATEGORIES[@]}"; do
  for skill in ${SKILL_STUBS[$sub]}; do
    skill_dir="$LANG_DIR/$sub/$skill"
    mkdir -p "$skill_dir"
    cat > "$skill_dir/SKILL.md" << EOF
---
name: ${LANGUAGE:0:2}-${skill}
description: TODO: describe what this skill does and when Claude should invoke it.
language: $LANGUAGE
used-by: ${USED_BY[$sub]}
# disable-model-invocation: false
---

TODO: Write the skill instructions here.

\$ARGUMENTS
EOF
    echo "  Created: skills/$LANGUAGE/$sub/$skill/SKILL.md"
  done
done

echo ""
echo "Registering paths in plugin.json..."

# Build the new skill paths to insert
NEW_PATHS=""
for sub in "${SUBCATEGORIES[@]}"; do
  NEW_PATHS="$NEW_PATHS    \"./skills/$LANGUAGE/$sub\","$'\n'
done

# Insert before the closing ] of the skills array using Python for reliable JSON editing
python3 - "$PLUGIN_JSON" "$LANGUAGE" "${SUBCATEGORIES[@]}" << 'PYEOF'
import sys, json

plugin_json_path = sys.argv[1]
language = sys.argv[2]
subcategories = sys.argv[3:]

with open(plugin_json_path) as f:
    data = json.load(f)

new_paths = [f"./skills/{language}/{sub}" for sub in subcategories]
existing = set(data.get("skills", []))
to_add = [p for p in new_paths if p not in existing]

data["skills"] = data.get("skills", []) + to_add

with open(plugin_json_path, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")

print(f"  Added {len(to_add)} paths to plugin.json")
PYEOF

HOOK_SCRIPT="$PLUGIN_DIR/scripts/hooks/format-${LANGUAGE}.sh"
cat > "$HOOK_SCRIPT" << EOF
#!/usr/bin/env bash
# format-${LANGUAGE}.sh — Auto-format ${LANGUAGE} files after Claude writes/edits them.
# TODO: add formatter command here
set -euo pipefail
# Exit silently if formatter not installed
EOF
chmod +x "$HOOK_SCRIPT"
echo "  Created: scripts/hooks/format-${LANGUAGE}.sh (stub — fill in your formatter)"

echo ""
echo "Done. Next steps:"
echo "  1. Fill in the SKILL.md files in skills/$LANGUAGE/"
echo "  2. Add a language-specific agent in agents/ if needed"
echo "  3. Add a formatting hook for .$LANGUAGE files in hooks/hooks.json:"
echo ""
echo "     {"
echo "       \"type\": \"command\","
echo "       \"command\": \"\${CLAUDE_PLUGIN_ROOT}/scripts/hooks/format-${LANGUAGE}.sh\""
echo "     }"
echo ""
echo "     Then fill in scripts/hooks/format-${LANGUAGE}.sh with your formatter."
echo "     See scripts/hooks/format-python.sh for a reference implementation."
echo ""
echo "  4. Test with: claude --plugin-dir $PLUGIN_DIR"
