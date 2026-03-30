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

# ── 2b. Agent paths in plugin.json ───────────────────────────────────────────
echo "── Agent paths ──"
AGENT_PATHS=$(python3 -c "
import json
with open('$PLUGIN_JSON') as f:
    d = json.load(f)
for p in d.get('agents', []):
    print(p)
" 2>/dev/null)

AGENT_PATH_ERRORS=0
while IFS= read -r path; do
  abs="$PLUGIN_DIR/${path#./}"
  if [ ! -f "$abs" ]; then
    error "agent path '$path' in plugin.json does not exist on disk"
    ((AGENT_PATH_ERRORS++)) || true
  else
    green "$path"
  fi
done <<< "$AGENT_PATHS"
if [ "$AGENT_PATH_ERRORS" -eq 0 ]; then
  count=$(echo "$AGENT_PATHS" | grep -c . || true)
  green "$count agent paths validated"
fi
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

  # Check 12: language value is valid
  if grep -q "^language:" "$skill_file" 2>/dev/null; then
    lang_val=$(grep "^language:" "$skill_file" | head -1 | sed 's/^language: *//')
    case "$lang_val" in
      python|javascript|go|common) ;;
      *) error "$rel: invalid language value '$lang_val' (must be python, javascript, go, or common)" ; ((SKILL_ERRORS++)) || true ;;
    esac

    # Check 13: language must match directory path
    case "$lang_val" in
      python|javascript|go)
        if [[ "$skill_file" != *"/skills/${lang_val}/"* ]]; then
          error "$rel: language '$lang_val' but file is not under skills/${lang_val}/"
          ((SKILL_ERRORS++)) || true
        fi
        ;;
      common)
        if [[ "$skill_file" != *"/skills/common/"* ]]; then
          error "$rel: language 'common' but file is not under skills/common/"
          ((SKILL_ERRORS++)) || true
        fi
        ;;
    esac
  fi

  # Check 11: used-by values are valid agent roles
  if grep -q "^used-by:" "$skill_file" 2>/dev/null; then
    used_by_raw=$(grep "^used-by:" "$skill_file" | head -1 | sed 's/^used-by: *//')
    # Split on commas and spaces
    IFS=', ' read -ra used_by_tokens <<< "$used_by_raw"
    for token in "${used_by_tokens[@]}"; do
      [ -z "$token" ] && continue
      case "$token" in
        executor|reviewer|refactorer|debugger|performance|context|planner|standalone) ;;
        *) warning "$rel: unknown used-by value '$token'" ;;
      esac
    done
  fi

done < <(find "$PLUGIN_DIR/skills" -name "SKILL.md" | sort)

if [ "$SKILL_ERRORS" -eq 0 ]; then
  total=$(find "$PLUGIN_DIR/skills" -name "SKILL.md" | wc -l | tr -d ' ')
  green "$total SKILL.md files validated"
fi
echo ""

# ── 4. Agent frontmatter ──────────────────────────────────────────────────────
echo "── Agent files ──"
AGENT_ERRORS=0
SEEN_AGENT_NAMES=()

while IFS= read -r agent_file; do
  rel="${agent_file#$PLUGIN_DIR/}"
  for field in name description; do
    if ! grep -q "^${field}:" "$agent_file" 2>/dev/null; then
      error "$rel: missing frontmatter field '$field'"
      ((AGENT_ERRORS++)) || true
    fi
  done

  # Check 10: duplicate agent names
  agent_name=$(grep "^name:" "$agent_file" | head -1 | sed 's/^name: *//')
  if [ -n "$agent_name" ]; then
    if [[ " ${SEEN_AGENT_NAMES[*]+"${SEEN_AGENT_NAMES[*]}"} " == *" $agent_name "* ]]; then
      error "$rel: duplicate agent name '$agent_name'"
      ((AGENT_ERRORS++)) || true
    fi
    SEEN_AGENT_NAMES+=("$agent_name")
  fi
done < <(find "$PLUGIN_DIR/agents" -name "*.md" | sort)

if [ "$AGENT_ERRORS" -eq 0 ]; then
  total=$(find "$PLUGIN_DIR/agents" -name "*.md" | wc -l | tr -d ' ')
  green "$total agent files validated"
fi
echo ""

# ── 4b. Language skill subcategory coverage ───────────────────────────────────
echo "── Language subcategories ──"
REQUIRED_SUBCATS=(generation refactoring testing analysis debugging)
for lang_dir in "$PLUGIN_DIR/skills"/*/; do
  lang=$(basename "$lang_dir")
  [ "$lang" = "common" ] && continue
  [ "$lang" = "templates" ] && continue
  for subcat in "${REQUIRED_SUBCATS[@]}"; do
    subcat_dir="$lang_dir$subcat"
    if [ ! -d "$subcat_dir" ]; then
      warning "skills/$lang/$subcat/ missing — routing block will emit an empty skill path"
    else
      count=$(find "$subcat_dir" -name "SKILL.md" | wc -l | tr -d ' ')
      if [ "$count" -eq 0 ]; then
        warning "skills/$lang/$subcat/ exists but contains no SKILL.md files"
      else
        green "skills/$lang/$subcat ($count skills)"
      fi
    fi
  done
done
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

# ── 8. Routing block consistency ──────────────────────────────────────────────
echo "── Routing block consistency ──"

ROUTER_FILE="$PLUGIN_DIR/agents/language-router.md"
CONTRACT_FILE="$PLUGIN_DIR/docs/contracts/routing-block.md"
CONTEXT_FILE="$PLUGIN_DIR/agents/context.md"

if [ -f "$ROUTER_FILE" ] && [ -f "$CONTRACT_FILE" ]; then
  # Check that language-router.md uses underscore field names (not spaces)
  if grep -qP "^EXECUTOR SKILLS:|^REVIEWER SKILLS:|^COMMON SKILLS:" "$ROUTER_FILE" 2>/dev/null; then
    error "language-router.md uses space-separated field names (EXECUTOR SKILLS) — must use underscores (EXECUTOR_SKILLS)"
  else
    green "language-router.md field names use underscores"
  fi

  # Check NEXT value matches contract (must be 'context', not 'context-agent')
  if grep -q "NEXT: context-agent" "$ROUTER_FILE" 2>/dev/null; then
    error "language-router.md emits 'NEXT: context-agent' but contract requires 'NEXT: context'"
  else
    green "language-router.md NEXT value matches contract"
  fi

  # Check that context.md preconditions reference EXECUTOR_SKILLS (not EXECUTOR SKILLS)
  if grep -q "EXECUTOR SKILLS" "$CONTEXT_FILE" 2>/dev/null; then
    error "context.md preconditions reference 'EXECUTOR SKILLS' (space) — must match routing block field name 'EXECUTOR_SKILLS'"
  else
    green "context.md precondition field names consistent"
  fi

  # Check that PIPELINE field is present in router output
  if ! grep -q "^PIPELINE:" "$ROUTER_FILE" 2>/dev/null; then
    error "language-router.md routing block is missing the PIPELINE field"
  else
    green "language-router.md PIPELINE field present"
  fi
else
  warning "skipping routing block consistency check (language-router.md or routing-block.md not found)"
fi
echo ""

# ── 9. hooks.json script references ──────────────────────────────────────────
echo "── hooks.json ──"
HOOKS_JSON="$PLUGIN_DIR/hooks/hooks.json"
if [ -f "$HOOKS_JSON" ]; then
  hook_scripts=$(python3 -c "
import json, sys
with open('$HOOKS_JSON') as f:
    d = json.load(f)
for event_hooks in d.get('hooks', {}).values():
    for entry in event_hooks:
        for h in entry.get('hooks', []):
            cmd = h.get('command', '')
            if cmd:
                # Strip variable prefix so we can resolve against PLUGIN_DIR
                print(cmd.replace('\${CLAUDE_PLUGIN_ROOT}/', '').replace('\${PLUGIN_DIR}/', ''))
" 2>/dev/null)
  while IFS= read -r rel_script; do
    [ -z "$rel_script" ] && continue
    abs_script="$PLUGIN_DIR/$rel_script"
    if [ ! -f "$abs_script" ]; then
      error "hooks.json references non-existent script: $rel_script"
    elif [ ! -x "$abs_script" ]; then
      error "hooks.json script not executable: $rel_script (run: chmod +x $rel_script)"
    else
      green "$rel_script referenced in hooks.json and executable"
    fi
  done <<< "$hook_scripts"
else
  green "no hooks.json found (skipping)"
fi
echo ""

# ── 10. settings.json validation ─────────────────────────────────────────────
echo "── settings.json ──"
SETTINGS_JSON="$PLUGIN_DIR/settings.json"
if [ -f "$SETTINGS_JSON" ]; then
  settings_output=$(python3 - "$SETTINGS_JSON" "${SEEN_NAMES[*]:-}" "${SEEN_AGENT_NAMES[*]:-}" <<'PYEOF'
import json, sys

path = sys.argv[1]
skill_names = set(sys.argv[2].split()) if sys.argv[2] else set()
agent_names = set(sys.argv[3].split()) if sys.argv[3] else set()

VALID_OUTPUT_STYLES = {"Explanatory", "Concise"}
VALID_DISABLE_AGENTS = {"refactorer", "performance", "debugger"}

try:
    with open(path) as f:
        d = json.load(f)
except json.JSONDecodeError as e:
    print(f"ERROR invalid JSON: {e}")
    sys.exit(0)

style = d.get("outputStyle")
if style and style not in VALID_OUTPUT_STYLES:
    print(f"ERROR outputStyle '{style}' is invalid (must be: {', '.join(sorted(VALID_OUTPUT_STYLES))})")

for a in d.get("pipeline", {}).get("disableAgents", []):
    if a not in VALID_DISABLE_AGENTS:
        print(f"ERROR pipeline.disableAgents: '{a}' is not a valid optional agent (valid: refactorer, performance, debugger)")

entry = d.get("agent")
if entry and agent_names and entry not in agent_names:
    print(f"WARN agent '{entry}' not found in agents/ directory")

if skill_names:
    for sk in d.get("skills", {}).get("exclude", []):
        if sk not in skill_names:
            print(f"WARN skills.exclude: '{sk}' does not match any registered skill name")
    for sk in d.get("skills", {}).get("include", []):
        if sk not in skill_names:
            print(f"WARN skills.include: '{sk}' does not match any registered skill name")
PYEOF
  )
  SETTINGS_ISSUES=0
  while IFS= read -r line; do
    case "$line" in
      ERROR\ *) error "settings.json: ${line#ERROR }"; ((SETTINGS_ISSUES++)) || true ;;
      WARN\ *)  warning "settings.json: ${line#WARN }";  ((SETTINGS_ISSUES++)) || true ;;
    esac
  done <<< "$settings_output"
  if [ "$SETTINGS_ISSUES" -eq 0 ]; then
    green "settings.json validated"
  fi
else
  green "no settings.json found (skipping)"
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
