#!/bin/sh
cmd=$(jq -r '.tool_input.command // ""')
case "$cmd" in
  *"gh issue create"*)
    printf '%s' "$cmd" | grep -Eq -- '(--label|-l)[ =][^ -]' && exit 0 ;;
  *"gh api"*issues*title=*)
    printf '%s' "$cmd" | grep -Eq -- 'labels(\[\])?=' && exit 0 ;;
  *) exit 0 ;;
esac
echo "Blocked: issue without a label. Add --label (e.g. --label needs-triage). A leftover found during a map run belongs on the map as a sub-issue, not a standalone issue." >&2
exit 2
