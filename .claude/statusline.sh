#!/bin/bash
# Claude Code status line: ctx tokens/% + 5h session limit, then dir + git.
input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
dir=$(basename "$cwd")

read -r used pct sess < <(echo "$input" | jq -r '[
  ((.context_window.total_input_tokens // 0) + (.context_window.total_output_tokens // 0)),
  (.context_window.used_percentage // 0),
  (.rate_limits.five_hour.used_percentage // -1)
] | @tsv')

k=$(( used / 1000 ))
meter="ctx ${k}k (${pct%.*}%)"
[ "${sess%.*}" -ge 0 ] 2>/dev/null && meter="$meter · 5h ${sess%.*}%"

if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
  branch=$(git -C "$cwd" -c core.fsmonitor=false symbolic-ref --short HEAD 2>/dev/null || echo detached)
  if ! git -C "$cwd" -c core.fsmonitor=false diff --quiet 2>/dev/null || ! git -C "$cwd" -c core.fsmonitor=false diff --cached --quiet 2>/dev/null; then st=" ✗"; else st=""; fi
  git_info=$(printf " \033[1;34mgit:(\033[0;31m%s\033[1;34m)%s\033[0m" "$branch" "$st")
fi

printf "\033[1;32m➜\033[0m  \033[0;36m%s\033[0m%s  \033[0;90m%s\033[0m" "$dir" "$git_info" "$meter"
