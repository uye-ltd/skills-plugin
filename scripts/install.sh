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

# Step 2.5 — Inject full plugin settings (all tools + skills pre-listed) into project settings
PROJECT_SETTINGS="$TARGET/.claude/settings.json"
if [ -f "$PROJECT_SETTINGS" ]; then
  echo "Populating plugin settings in $PROJECT_SETTINGS..."
  tmp=$(mktemp)
  if command -v jq >/dev/null 2>&1; then
    # Build sorted JSON arrays from the plugin's tools and skills on this machine.
    tools_json=$(jq -rs '[.[].name] | sort' "$PLUGIN_DIR"/config/tools/*.json)
    skills_json=$(find "$PLUGIN_DIR/skills" -name "SKILL.md" \
      -exec grep -h '^name:' {} + \
      | sed 's/name:[[:space:]]*//' | sort | jq -R . | jq -s .)
    # Build full defaults: base settings.json + populated arrays.
    defaults=$(jq --argjson t "$tools_json" --argjson s "$skills_json" \
      '.tools = $t | .skills.include = $s' "$PLUGIN_DIR/settings.json")
    # Merge: existing project values win on collision; defaults fill gaps.
    jq --argjson d "$defaults" '$d + .' "$PROJECT_SETTINGS" > "$tmp" && mv "$tmp" "$PROJECT_SETTINGS"
  elif command -v python3 >/dev/null 2>&1; then
    python3 - "$PLUGIN_DIR" "$PROJECT_SETTINGS" <<'PYEOF'
import json, os, sys, glob, re
plugin_dir, project_path = sys.argv[1], sys.argv[2]
with open(os.path.join(plugin_dir, "settings.json")) as f:
    defaults = json.load(f)
defaults["tools"] = sorted(
    json.load(open(p))["name"]
    for p in glob.glob(os.path.join(plugin_dir, "config/tools/*.json"))
)
skills = []
for p in sorted(glob.glob(os.path.join(plugin_dir, "skills/**/*.md"), recursive=True)):
    if os.path.basename(p) == "SKILL.md":
        for line in open(p):
            m = re.match(r"^name:\s*(.+)", line)
            if m:
                skills.append(m.group(1).strip())
                break
defaults["skills"]["include"] = skills
with open(project_path) as f:
    project = json.load(f)
merged = {**defaults, **project}
with open(project_path, "w") as f:
    json.dump(merged, f, indent=2)
PYEOF
  else
    echo "  Warning: neither jq nor python3 found — add plugin settings manually from:"
    echo "  $PLUGIN_DIR/settings.json"
  fi
fi

# Step 3 — Install statusline script to ~/.claude/ and configure ~/.claude/settings.json
STATUSLINE_SRC="$PLUGIN_DIR/scripts/statusline-command.sh"
STATUSLINE_DEST="$HOME/.claude/statusline-command.sh"
CLAUDE_SETTINGS="$HOME/.claude/settings.json"

echo "Installing statusline script..."
cp "$STATUSLINE_SRC" "$STATUSLINE_DEST"
chmod +x "$STATUSLINE_DEST"

if [ -f "$CLAUDE_SETTINGS" ] && command -v jq >/dev/null 2>&1; then
  tmp=$(mktemp)
  jq --arg cmd "bash $STATUSLINE_DEST" \
    'if .statusLine then . else . + {"statusLine": {"type": "command", "command": $cmd}} end' \
    "$CLAUDE_SETTINGS" > "$tmp" && mv "$tmp" "$CLAUDE_SETTINGS"
  echo "  statusLine configured in $CLAUDE_SETTINGS"
else
  echo "  Warning: jq not found or $CLAUDE_SETTINGS missing — add statusLine manually:"
  printf '    { "statusLine": { "type": "command", "command": "bash %s" } }\n' "$STATUSLINE_DEST"
fi

echo ""
echo "Done. Three things happened:"
echo "  1. $PLUGIN_DIR registered as a marketplace in your user config (~/.claude/)"
echo "     Re-running install.sh is safe — marketplace registration is idempotent."
echo "  2. The 'uye' plugin installed at project scope in $TARGET/.claude/settings.json"
echo "  3. Statusline script installed to $STATUSLINE_DEST"
echo ""
echo "Commit the settings file to share the plugin with your team:"
echo ""
echo "  git add .claude/settings.json && git commit -m 'chore: add uye claude plugin'"
echo ""
echo "Note: each developer needs to run install.sh once (or any install) to register"
echo "the marketplace on their machine before the plugin activates for them."
