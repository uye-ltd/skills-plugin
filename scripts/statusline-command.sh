#!/usr/bin/env sh
# Claude Code status line
input=$(cat)

# --- Color support detection ---
USE_COLOR=""
case "$TERM" in
  xterm*|rxvt*|screen*|tmux*|ansi|vt100|linux|*color*)
    USE_COLOR="1" ;;
esac
if [ -z "$USE_COLOR" ] && command -v tput >/dev/null 2>&1; then
  n=$(tput colors 2>/dev/null)
  [ "${n:-0}" -ge 8 ] && USE_COLOR="1"
fi

# --- Colors (ANSI; ORANGE uses 256-color escape, degrades gracefully) ---
RESET=""
BOLD=""
CYAN=""
YELLOW=""
ORANGE=""
GREEN=""
MAGENTA=""
RED=""
GREY=""
if [ -n "$USE_COLOR" ]; then
  RESET="\033[0m"
  BOLD="\033[1m"
  CYAN="\033[36m"
  YELLOW="\033[33m"
  ORANGE="\033[38;5;208m"
  GREEN="\033[32m"
  MAGENTA="\033[35m"
  RED="\033[31m"
  GREY="\033[90m"
fi

# Pick color for a percentage value (0-100): green / yellow / orange / red
pct_color() {
  _v="$1"
  if [ "$_v" -ge 95 ]; then
    printf '%s' "$RED"
  elif [ "$_v" -ge 75 ]; then
    printf '%s' "$ORANGE"
  elif [ "$_v" -ge 40 ]; then
    printf '%s' "$YELLOW"
  else
    printf '%s' "$GREEN"
  fi
}

# Format Unix epoch as local time: H:MMam
_fmt_time() {
  _e="$1"
  _h=$(date -r "$_e" "+%I" 2>/dev/null || date -d "@$_e" "+%I" 2>/dev/null)
  _h=$(printf '%s' "${_h:-0}" | sed 's/^0//')
  _m=$(date -r "$_e" "+%M" 2>/dev/null || date -d "@$_e" "+%M" 2>/dev/null)
  _ap=$(date -r "$_e" "+%p" 2>/dev/null || date -d "@$_e" "+%p" 2>/dev/null)
  _ap=$(printf '%s' "${_ap:-}" | tr 'A-Z' 'a-z')
  printf '%s:%s%s' "${_h:-?}" "${_m:---}" "$_ap"
}

# Format Unix epoch as local date + time: DD-MMT H:MMam  (e.g. 01-05T3:00am)
_fmt_date_time() {
  _e="$1"
  _dm=$(date -r "$_e" "+%d-%m" 2>/dev/null || date -d "@$_e" "+%d-%m" 2>/dev/null)
  printf '%sT%s' "${_dm:-?-?}" "$(_fmt_time "$_e")"
}

# --- Directory (tilde-prefixed) ---
cwd=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd')
home="$HOME"
case "$cwd" in
  "$home"*) short_dir="~${cwd#$home}" ;;
  *)        short_dir="$cwd" ;;
esac

# --- Git branch + dirty flag ---
git_branch=""
git_dirty=""
if git_out=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null); then
  git_branch="$git_out"
elif git_out=$(git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null); then
  git_branch="$git_out"
fi
if [ -n "$git_branch" ]; then
  if [ -n "$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)" ]; then
    git_dirty="1"
  fi
fi

# --- Model ID — shorten to e.g. "sonnet4.6" ---
model_raw=$(printf '%s' "$input" | jq -r '.model.id // .model.display_name // empty')
model=""
if [ -n "$model_raw" ]; then
  model="${model_raw#claude-}"
  model=$(printf '%s' "$model" | sed -E 's/-([0-9]+)-([0-9]+)$/\1.\2/')
  model=$(printf '%s' "$model" | sed -E 's/-([0-9])/\1/g')
fi

# --- Agent name (present only when running with --agent or agent settings) ---
agent_name=$(printf '%s' "$input" | jq -r '.agent.name // empty')

# --- Context usage % ---
used=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty')

# --- Rate limits: usage % and reset timestamps (resets_at is Unix epoch integer) ---
rl_five=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
rl_week=$(printf '%s' "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
rl_five_reset=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
rl_week_reset=$(printf '%s' "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

# --- Token count (cumulative input + output), compacted to Nk ---
total_in=$(printf '%s' "$input" | jq -r '.context_window.total_input_tokens // 0')
total_out=$(printf '%s' "$input" | jq -r '.context_window.total_output_tokens // 0')
token_total=$((total_in + total_out))
token_compact=""
token_k=0
if [ "$token_total" -gt 0 ] 2>/dev/null; then
  token_k=$(( (token_total + 500) / 1000 ))
  token_compact="${token_k}k"
fi

# --- Session cost ---
cost_raw=$(printf '%s' "$input" | jq -r '
  .cost.total_cost_usd //
  .session_cost.total_cost_usd //
  (if (.cost | type) == "number" then .cost else null end) //
  empty')
cost=""
if [ -n "$cost_raw" ]; then
  cost=$(printf "%.2f" "$cost_raw" 2>/dev/null) || cost=""
fi

# --- Build output ---
SEP=" "
parts=""

# 1. Directory — bold cyan
parts="${parts}$(printf "${BOLD}${CYAN}%s${RESET}" "$short_dir")"

# 2. Git branch — green; dirty asterisk in yellow
if [ -n "$git_branch" ]; then
  if [ -n "$git_dirty" ]; then
    parts="${parts}${SEP}$(printf "${GREEN}%s${RESET}${YELLOW}*${RESET}" "$git_branch")"
  else
    parts="${parts}${SEP}$(printf "${GREEN}%s${RESET}" "$git_branch")"
  fi
fi

# 3. Model — magenta
if [ -n "$model" ]; then
  parts="${parts}${SEP}$(printf "${MAGENTA}%s${RESET}" "$model")"
fi

# 4. Agent name — orange, prefixed with @
if [ -n "$agent_name" ]; then
  parts="${parts}${SEP}$(printf "${ORANGE}@%s${RESET}" "$agent_name")"
fi

# 5. Three percentages: ctx / 5h / 7d — each colorized independently, / not colorized
used_int=""
[ -n "$used" ] && used_int=$(printf "%.0f" "$used")
five_int=""
[ -n "$rl_five" ] && five_int=$(printf "%.0f" "$rl_five")
week_int=""
[ -n "$rl_week" ] && week_int=$(printf "%.0f" "$rl_week")

if [ -n "$used_int" ]; then
  slot1="$(pct_color "$used_int")${used_int}%${RESET}"
else
  slot1="..."
fi
if [ -n "$five_int" ]; then
  slot2="$(pct_color "$five_int")${five_int}%${RESET}"
else
  slot2="..."
fi
if [ -n "$week_int" ]; then
  slot3="$(pct_color "$week_int")${week_int}%${RESET}"
else
  slot3="..."
fi

pct_field="${slot1}${RESET}/${slot2}${RESET}/${slot3}"
parts="${parts}${SEP}$(printf "%b" "$pct_field")"

# 5. Tokens/cost — tokens colored by count, / plain, cost colored by dollar amount
tokens_cost=""
if [ -n "$token_compact" ]; then
  if [ "$token_k" -gt 200 ]; then
    tok_color="$RED"
  elif [ "$token_k" -gt 100 ]; then
    tok_color="$ORANGE"
  elif [ "$token_k" -gt 50 ]; then
    tok_color="$YELLOW"
  else
    tok_color="$GREEN"
  fi
  tokens_cost="$(printf "${tok_color}%s${RESET}" "$token_compact")"
fi
if [ -n "$cost" ]; then
  cost_cents=$(awk "BEGIN {printf \"%.0f\", $cost * 100}" 2>/dev/null) || cost_cents=0
  if [ "${cost_cents:-0}" -gt 2000 ]; then
    cost_color="$RED"
  elif [ "${cost_cents:-0}" -gt 1000 ]; then
    cost_color="$ORANGE"
  elif [ "${cost_cents:-0}" -gt 500 ]; then
    cost_color="$YELLOW"
  else
    cost_color="$GREEN"
  fi
  cost_str="$(printf "${cost_color}\$%s${RESET}" "$cost")"
  if [ -n "$tokens_cost" ]; then
    tokens_cost="${tokens_cost}${RESET}/${cost_str}"
  else
    tokens_cost="$cost_str"
  fi
fi
if [ -n "$tokens_cost" ]; then
  parts="${parts}${SEP}$(printf "%b" "$tokens_cost")"
fi

# 7. Rate limit reset times — grey: 5h as H:MMam / 7d as DD-MMT H:MMam
reset_field=""
if [ -n "$rl_five_reset" ]; then
  reset_field="$(_fmt_time "$rl_five_reset")"
fi
if [ -n "$rl_week_reset" ]; then
  [ -n "$reset_field" ] && reset_field="${reset_field}/"
  reset_field="${reset_field}$(_fmt_date_time "$rl_week_reset")"
fi
if [ -n "$reset_field" ]; then
  parts="${parts}${SEP}$(printf "${GREY}%s${RESET}" "$reset_field")"
fi

printf "%b\n" "$parts"
