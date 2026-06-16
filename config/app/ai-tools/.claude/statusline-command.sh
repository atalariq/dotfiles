#!/usr/bin/env bash

# ─── TOGGLE FLAGS ────────────────────────────────────────────────
SHOW_PATH=true
SHOW_BRANCH=true
SHOW_DIRTY=false
SHOW_WORKTREE=true
SHOW_MODEL=true # always paired with effort if SHOW_EFFORT=true
SHOW_EFFORT=true
SHOW_CTX=true
SHOW_COST=true
SHOW_LINES=true
SHOW_RATELIMIT=true
SHOW_SESSION=true
# ─────────────────────────────────────────────────────────────────

input=$(cat)

# ─── Raw values ──────────────────────────────────────────────────
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
model=$(echo "$input" | jq -r '.model.display_name // .model.id // ""')
effort=$(echo "$input" | jq -r '.effort.level // ""')
session=$(echo "$input" | jq -r '.session_name // ""')
ctx=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
added=$(echo "$input" | jq -r '.cost.total_lines_added // empty')
removed=$(echo "$input" | jq -r '.cost.total_lines_removed // empty')
rate5h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
worktree=$(echo "$input" | jq -r '.workspace.git_worktree // empty')

# ─── Noctalia 24-bit colors ──────────────────────────────────────
R='\033[0m'
BLUE='\033[38;2;127;187;179m'    # #7fbbb3  path
YELLOW='\033[38;2;219;188;127m'  # #dbbc7f  branch / rate5h warn
MAGENTA='\033[38;2;214;153;182m' # #d699b6  worktree / session
MUTED='\033[38;2;166;176;160m'   # #a6b0a0  model, cost
GREEN='\033[38;2;167;192;128m'   # #a7c080  lines added, prompt
CYAN='\033[38;2;131;192;146m'    # #83c092  ctx ok
RED='\033[38;2;230;126;128m'     # #e67e80  ctx warn / dirty
ORANGE='\033[38;2;223;160;0m'    # #dfa000  rate5h ok

SEP="${MUTED} | ${R}"

# ─── Build parts array ───────────────────────────────────────────
parts=()

# pwd — basename only
if $SHOW_PATH && [ -n "$cwd" ]; then
  basename="${cwd##*/}"
  [ "$cwd" = "$HOME" ] && basename="~"
  parts+=("${BLUE}${basename}${R}")
fi

# git branch (+ optional dirty marker)
if $SHOW_BRANCH; then
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    dirty_mark=""
    if $SHOW_DIRTY; then
      git -C "$cwd" --no-optional-locks diff --quiet 2>/dev/null || dirty_mark="${RED}*${R}"
    fi
    parts+=("${YELLOW} ${branch}${R}${dirty_mark}")
  fi
fi

# worktree
if $SHOW_WORKTREE && [ -n "$worktree" ]; then
  parts+=("${MAGENTA}[${worktree}]${R}")
fi

# model (effort) — merged
if $SHOW_MODEL && [ -n "$model" ]; then
  model_lower=$(echo "$model" | tr '[:upper:]' '[:lower:]')
  if $SHOW_EFFORT && [ -n "$effort" ]; then
    parts+=("${MUTED}${model_lower} (${effort})${R}")
  else
    parts+=("${MUTED}${model_lower}${R}")
  fi
fi

# ctx %
if $SHOW_CTX && [ -n "$ctx" ]; then
  pct=$(printf '%.0f' "$ctx")
  if [ "$pct" -ge 80 ]; then
    parts+=("${RED}ctx:${pct}%${R}")
  else
    parts+=("${CYAN}ctx:${pct}%${R}")
  fi
fi

# cost
if $SHOW_COST && [ -n "$cost" ]; then
  cost_fmt=$(printf '%.3f' "$cost")
  parts+=("${MUTED}\$${cost_fmt}${R}")
fi

# lines added/removed
if $SHOW_LINES && [ -n "$added" ] && [ -n "$removed" ]; then
  parts+=("${GREEN}+${added}${MUTED}-${removed}${R}")
fi

# rate limit 5h
if $SHOW_RATELIMIT && [ -n "$rate5h" ]; then
  pct5h=$(printf '%.0f' "$rate5h")
  if [ "$pct5h" -ge 80 ]; then
    parts+=("${RED}5h:${pct5h}%${R}")
  elif [ "$pct5h" -ge 50 ]; then
    parts+=("${YELLOW}5h:${pct5h}%${R}")
  else
    parts+=("${ORANGE}5h:${pct5h}%${R}")
  fi
fi

# session
if $SHOW_SESSION && [ -n "$session" ]; then
  parts+=("${MAGENTA}${session}${R}")
fi

# ─── Render one line ─────────────────────────────────────────────
out=""
for i in "${!parts[@]}"; do
  [ $i -gt 0 ] && out+=$(printf "%b" "$SEP")
  out+=$(printf "%b" "${parts[$i]}")
done

printf "%b\n" "${GREEN}❯${R} ${out}"
