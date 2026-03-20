#!/usr/bin/env bash
# validate.sh — Validate the plugin structure.
#
# Checks:
#   - Every SKILL.md has required frontmatter (name, description, language, used-by)
#   - Every agent .md has required frontmatter (name, description)
#   - Every path in plugin.json "skills" array exists on disk
#   - Every skills path directory contains at least one SKILL.md
#   - No duplicate skill names across the plugin
#
# Usage:
#   ./scripts/validate.sh
#   ./scripts/validate.sh --strict    # treat warnings as errors

set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGIN_JSON="$PLUGIN_DIR/.claude-plugin/plugin.json"
STRICT="${1:-}"

ERRORS=0
WARNINGS=0

red()    { printf "\033[31m✘ %s\033[0m\n" "$*"; }
yellow() { printf "\033[33m⚠ %s\033[0m\n" "$*"; }
green()  { printf "\033[32m✔ %s\033[0m\n" "$*"; }

error()   { red "$*";    ((ERRORS++))   || true; }
warning() { yellow "$*"; ((WARNINGS++)) || true; }

echo "Validating uye plugin..."
echo ""

# ── 1. Plugin manifest ────────────────────────────────────────────────────────
echo "── Manifest ──"
if [ ! -f "$PLUGIN_JSON" ]; then
  error "Missing .claude-plugin/plugin.json"
else
  green ".claude-plugin/plugin.json exists"
  for field in name version description; do
    if python3 -c "import json,sys; d=json.load(open('$PLUGIN_JSON')); sys.exit(0 if '$field' in d else 1)" 2>/dev/null; then
      green "  field '$field' present"
    else
      error "  Missing required field '$field' in plugin.json"
    fi
  done
fi
echo ""

# ── 2. Skill paths in plugin.json ─────────────────────────────────────────────
echo "── Skill paths ──"
SKILL_PATHS=$(python3 -c "
import json
with open('$PLUGIN_JSON') as f:
    d = json.load(f)
for p in d.get('skills', []):
    print(p)
" 2>/dev/null)

while IFS= read -r path; do
  abs="$PLUGIN_DIR/${path#./}"
  if [ ! -d "$abs" ]; then
    error "skills path '$path' in plugin.json does not exist on disk"
  else
    count=$(find "$abs" -name "SKILL.md" | wc -l | tr -d ' ')
    if [ "$count" -eq 0 ]; then
      warning "skills path '$path' exists but contains no SKILL.md files"
    else
      green "$path ($count skills)"
    fi
  fi
done <<< "$SKILL_PATHS"
echo ""

# ── 3. SKILL.md frontmatter ───────────────────────────────────────────────────
echo "── SKILL.md files ──"
SEEN_NAMES=()
SKILL_ERRORS=0

while IFS= read -r skill_file; do
  rel="${skill_file#$PLUGIN_DIR/}"

  for field in name description; do
    if ! grep -q "^${field}:" "$skill_file" 2>/dev/null; then
      error "$rel: missing frontmatter field '$field'"
      ((SKILL_ERRORS++)) || true
    fi
  done

  for field in language used-by; do
    if ! grep -q "^${field}:" "$skill_file" 2>/dev/null; then
      warning "$rel: missing recommended frontmatter field '$field'"
    fi
  done

  # Validate template: field if present
  if grep -q "^template:" "$skill_file" 2>/dev/null; then
    tmpl=$(grep "^template:" "$skill_file" | head -1 | sed 's/^template: *//')
    tmpl_file="$PLUGIN_DIR/skills/templates/${tmpl}.md"
    if [ ! -f "$tmpl_file" ]; then
      error "$rel: template '$tmpl' not found at skills/templates/${tmpl}.md"
    fi
  fi

  # Check for duplicate names
  name=$(grep "^name:" "$skill_file" | head -1 | sed 's/^name: *//')
  if [[ " ${SEEN_NAMES[*]+"${SEEN_NAMES[*]}"} " == *" $name "* ]]; then
    error "$rel: duplicate skill name '$name'"
  fi
  SEEN_NAMES+=("$name")

done < <(find "$PLUGIN_DIR/skills" -name "SKILL.md" | sort)

if [ "$SKILL_ERRORS" -eq 0 ]; then
  total=$(find "$PLUGIN_DIR/skills" -name "SKILL.md" | wc -l | tr -d ' ')
  green "$total SKILL.md files validated"
fi
echo ""

# ── 4. Agent frontmatter ──────────────────────────────────────────────────────
echo "── Agent files ──"
AGENT_ERRORS=0

while IFS= read -r agent_file; do
  rel="${agent_file#$PLUGIN_DIR/}"
  for field in name description; do
    if ! grep -q "^${field}:" "$agent_file" 2>/dev/null; then
      error "$rel: missing frontmatter field '$field'"
      ((AGENT_ERRORS++)) || true
    fi
  done
done < <(find "$PLUGIN_DIR/agents" -name "*.md" | sort)

if [ "$AGENT_ERRORS" -eq 0 ]; then
  total=$(find "$PLUGIN_DIR/agents" -name "*.md" | wc -l | tr -d ' ')
  green "$total agent files validated"
fi
echo ""

# ── 5. Hook scripts ───────────────────────────────────────────────────────────
echo "── Hook scripts ──"
if [ -d "$PLUGIN_DIR/scripts/hooks" ]; then
  while IFS= read -r script; do
    rel="${script#$PLUGIN_DIR/}"
    if [ ! -x "$script" ]; then
      error "$rel: not executable (run: chmod +x $rel)"
    else
      green "$rel is executable"
    fi
  done < <(find "$PLUGIN_DIR/scripts/hooks" -name "*.sh" | sort)
fi
echo ""

# ── 6. Contracts ──────────────────────────────────────────────────────────────
echo "── Contracts ──"

# Map pipeline agent name → expected contract filename (no associative arrays for bash 3.2 compat)
contract_for_agent() {
  case "$1" in
    language-router) echo "routing-block" ;;
    context)         echo "context-summary" ;;
    planner)         echo "implementation-plan" ;;
    executor)        echo "execution-summary" ;;
    reviewer)        echo "review-report" ;;
    debugger)        echo "debug-report" ;;
    refactorer)      echo "refactoring-summary" ;;
    performance)     echo "performance-report" ;;
    *)               echo "" ;;
  esac
}

while IFS= read -r agent_file; do
  agent_name=$(grep "^name:" "$agent_file" | head -1 | sed 's/^name: *//')
  if [ -z "$agent_name" ]; then
    continue
  fi

  contract=$(contract_for_agent "$agent_name")
  if [ -n "$contract" ]; then
    contract_file="$PLUGIN_DIR/docs/contracts/${contract}.md"
    if [ ! -f "$contract_file" ]; then
      error "pipeline agent '$agent_name' is missing contract: docs/contracts/${contract}.md"
    else
      green "  $agent_name → docs/contracts/${contract}.md"
    fi
  else
    warning "agent '$agent_name' is not a pipeline agent — no contract required (standalone OK)"
  fi
done < <(find "$PLUGIN_DIR/agents" -name "*.md" | sort)

echo ""

# ── 7. Tool configs ───────────────────────────────────────────────────────────
echo "── Tool configs ──"
TOOL_ERRORS=0
TOOL_COUNT=0

while IFS= read -r tool_file; do
  rel="${tool_file#$PLUGIN_DIR/}"
  stem=$(basename "$tool_file" .json)
  ((TOOL_COUNT++)) || true

  result=$(python3 - "$tool_file" "$stem" <<'PYEOF'
import json, sys

path, stem = sys.argv[1], sys.argv[2]
try:
    with open(path) as f:
        d = json.load(f)
except json.JSONDecodeError as e:
    print(f"invalid JSON: {e}")
    sys.exit(1)

errors = []
for key in ("name", "description"):
    if not d.get(key):
        errors.append(f"missing required field '{key}'")

github = d.get("github", {})
for key in ("org", "repo", "branch"):
    if not github.get(key):
        errors.append(f"missing required field 'github.{key}'")

docs = d.get("docs", {})
if not docs.get("url"):
    errors.append("missing required field 'docs.url'")

if d.get("name") and d["name"] != stem:
    errors.append(f"'name' field '{d['name']}' does not match filename stem '{stem}'")

for e in errors:
    print(e)
sys.exit(len(errors))
PYEOF
  )
  exit_code=$?

  if [ $exit_code -ne 0 ]; then
    while IFS= read -r msg; do
      error "$rel: $msg"
    done <<< "$result"
    ((TOOL_ERRORS++)) || true
  fi
done < <(find "$PLUGIN_DIR/config/tools" -name "*.json" 2>/dev/null | sort)

if [ "$TOOL_ERRORS" -eq 0 ] && [ "$TOOL_COUNT" -gt 0 ]; then
  green "$TOOL_COUNT tool configs validated"
elif [ "$TOOL_COUNT" -eq 0 ]; then
  green "no tool configs found (skipping)"
fi
echo ""

# ── Summary ───────────────────────────────────────────────────────────────────
echo "── Summary ──"
if [ "$ERRORS" -gt 0 ]; then
  red "$ERRORS error(s), $WARNINGS warning(s)"
  exit 1
elif [ "$WARNINGS" -gt 0 ] && [ "$STRICT" = "--strict" ]; then
  yellow "$WARNINGS warning(s) treated as errors (--strict)"
  exit 1
elif [ "$WARNINGS" -gt 0 ]; then
  yellow "0 errors, $WARNINGS warning(s)"
  exit 0
else
  green "All checks passed"
  exit 0
fi
