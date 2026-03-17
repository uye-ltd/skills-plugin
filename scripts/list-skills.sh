#!/usr/bin/env bash
# list-skills.sh — List all registered skills grouped by language and subcategory.
#
# Usage:
#   ./scripts/list-skills.sh                      # all skills
#   ./scripts/list-skills.sh python               # filter by language
#   ./scripts/list-skills.sh --used-by executor   # filter by consuming agent
#   ./scripts/list-skills.sh --names-only         # just skill names, one per line

set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

bold()  { printf "\033[1m%s\033[0m\n" "$*"; }
dim()   { printf "\033[2m%s\033[0m\n" "$*"; }
cyan()  { printf "\033[36m%s\033[0m" "$*"; }

NAMES_ONLY=false
LANG_FILTER=""
USED_BY_FILTER=""
USED_BY_NEXT=false

for arg in "$@"; do
  case "$arg" in
    --names-only) NAMES_ONLY=true ;;
    --used-by) USED_BY_NEXT=true ;;
    -*)  ;;
    *)
      if [ "$USED_BY_NEXT" = "true" ]; then
        USED_BY_FILTER="$arg"
        USED_BY_NEXT=false
      else
        LANG_FILTER="$arg"
      fi
      ;;
  esac
done

TOTAL=0
CURRENT_LANG=""
CURRENT_SUB=""

while IFS= read -r skill_file; do
  # Extract path components: skills/<lang>/<sub>/<skill>/SKILL.md
  rel="${skill_file#$PLUGIN_DIR/skills/}"
  lang=$(echo "$rel" | cut -d'/' -f1)
  sub=$(echo "$rel" | cut -d'/' -f2)

  # Apply language filter
  if [ -n "$LANG_FILTER" ] && [ "$lang" != "$LANG_FILTER" ]; then
    continue
  fi

  # Extract frontmatter fields
  name=$(grep "^name:" "$skill_file" 2>/dev/null | head -1 | sed 's/^name: *//')
  description=$(grep "^description:" "$skill_file" 2>/dev/null | head -1 | sed 's/^description: *//')
  used_by=$(grep "^used-by:" "$skill_file" 2>/dev/null | head -1 | sed 's/^used-by: *//')

  # Apply used-by filter
  if [ -n "$USED_BY_FILTER" ] && ! echo "$used_by" | grep -q "$USED_BY_FILTER"; then
    continue
  fi

  if $NAMES_ONLY; then
    echo "$name"
    ((TOTAL++)) || true
    continue
  fi

  # Print language header
  if [ "$lang" != "$CURRENT_LANG" ]; then
    [ -n "$CURRENT_LANG" ] && echo ""
    bold "── $lang ──────────────────────────────"
    CURRENT_LANG="$lang"
    CURRENT_SUB=""
  fi

  # Print subcategory header
  if [ "$sub" != "$CURRENT_SUB" ]; then
    echo ""
    printf "  \033[33m%s\033[0m\n" "$sub"
    CURRENT_SUB="$sub"
  fi

  # Print skill
  printf "    \033[36m/uye:%-30s\033[0m %s" "$name" ""
  if [ -n "$used_by" ]; then
    printf "\033[2m[%s]\033[0m" "$used_by"
  fi
  echo ""
  if [ -n "$description" ]; then
    printf "    \033[2m%s\033[0m\n" "${description:0:80}$([ ${#description} -gt 80 ] && echo '…' || true)"
  fi

  ((TOTAL++)) || true

done < <(find "$PLUGIN_DIR/skills" -name "SKILL.md" | sort)

if ! $NAMES_ONLY; then
  echo ""
  bold "Total: $TOTAL skills"
fi
