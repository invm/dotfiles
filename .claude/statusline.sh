#!/bin/bash
# Claude Code status line: ctx tokens/% + 5h + 7d limits, then dir + git.
input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
dir="$(basename "$(dirname "$cwd")")/$(basename "$cwd")"

read -r used pct s5 r5 s7 r7 < <(echo "$input" | jq -r '[
  ((.context_window.total_input_tokens // 0) + (.context_window.total_output_tokens // 0)),
  (.context_window.used_percentage // 0),
  (.rate_limits.five_hour.used_percentage // -1),
  (.rate_limits.five_hour.resets_at // 0),
  (.rate_limits.seven_day.used_percentage // -1),
  (.rate_limits.seven_day.resets_at // 0)
] | @tsv')

k=$(( used / 1000 ))
meter="ctx ${k}k (${pct%.*}%)"
now=$(date +%s)
limit() { # label used% resets_at
  [ "${2%.*}" -ge 0 ] 2>/dev/null || return
  left=""
  if [ "$3" -gt 0 ] 2>/dev/null; then
    secs=$(( $3 - now )); [ "$secs" -lt 0 ] && secs=0
    if [ "$secs" -ge 86400 ]; then left=" ($(( secs/86400 ))d$(( secs%86400/3600 ))h)"
    else left=" ($(( secs/3600 ))h$(( secs%3600/60 ))m)"; fi
  fi
  meter="$meter · $1 ${2%.*}%$left"
}
limit 5h "$s5" "$r5"
limit 7d "$s7" "$r7"

if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
  branch=$(git -C "$cwd" -c core.fsmonitor=false symbolic-ref --short HEAD 2>/dev/null || echo detached)
  if ! git -C "$cwd" -c core.fsmonitor=false diff --quiet 2>/dev/null || ! git -C "$cwd" -c core.fsmonitor=false diff --cached --quiet 2>/dev/null; then st=" ✗"; else st=""; fi
  git_info=$(printf " \033[1;34mgit:(\033[0;31m%s\033[1;34m)%s\033[0m" "$branch" "$st")
fi

printf "\033[1;32m➜\033[0m  \033[0;36m%s\033[0m%s  \033[0;90m%s\033[0m" "$dir" "$git_info" "$meter"
