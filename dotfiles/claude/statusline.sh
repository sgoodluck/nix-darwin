#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
CYAN='\033[36m'; GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'; GREY='\033[90m'; RESET='\033[0m'

# Git: branch + staged/modified
GIT=""
if GIT_OPTIONAL_LOCKS=0 git rev-parse --git-dir > /dev/null 2>&1; then
  B=$(GIT_OPTIONAL_LOCKS=0 git branch --show-current 2>/dev/null)
  if [ -n "$B" ]; then
    STAGED=$(GIT_OPTIONAL_LOCKS=0 git diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
    MODIFIED=$(GIT_OPTIONAL_LOCKS=0 git diff --numstat 2>/dev/null | wc -l | tr -d ' ')
    GIT=" | ${GREY}${B}${RESET}"
    [ "$STAGED" -gt 0 ] && GIT="${GIT} ${GREEN}+${STAGED}${RESET}"
    [ "$MODIFIED" -gt 0 ] && GIT="${GIT} ${YELLOW}~${MODIFIED}${RESET}"
  fi
fi

# Context bar color
if [ "$PCT" -ge 90 ]; then BAR_COLOR="$RED"
elif [ "$PCT" -ge 70 ]; then BAR_COLOR="$YELLOW"
else BAR_COLOR="$GREEN"; fi

FILLED=$((PCT / 10)); EMPTY=$((10 - FILLED))
BAR=$(printf "%${FILLED}s" | tr ' ' '█')$(printf "%${EMPTY}s" | tr ' ' '░')

COST_FMT=$(printf '$%.2f' "$COST")

echo -e "${CYAN}[${MODEL}]${RESET} ${DIR##*/}${GIT} | ${BAR_COLOR}${BAR}${RESET} ${PCT}% | ${YELLOW}${COST_FMT}${RESET}"
