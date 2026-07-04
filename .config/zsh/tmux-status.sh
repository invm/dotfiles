# Highlight tmux tab when command finishes in a non-visible window.
# Green on exit 0, red on non-zero. Skips commands shorter than 2s
# and the currently-focused window (no alert needed for what you see).

[[ -z "$TMUX" ]] && return

typeset -g _tmux_status_start=0

function _tmux_status_preexec {
  _tmux_status_start=$SECONDS
  tmux set-window-option -t "${TMUX_PANE}" @status running 2>/dev/null
}

function _tmux_status_precmd {
  local ec=$?
  local elapsed=$(( SECONDS - _tmux_status_start ))
  local active
  active=$(tmux display-message -p -t "${TMUX_PANE}" '#{window_active}' 2>/dev/null)
  if (( _tmux_status_start > 0 )) && (( elapsed >= 2 )) && [[ "$active" != "1" ]]; then
    if (( ec == 0 )); then
      tmux set-window-option -t "${TMUX_PANE}" @status done_ok 2>/dev/null
    else
      tmux set-window-option -t "${TMUX_PANE}" @status done_err 2>/dev/null
    fi
  else
    tmux set-window-option -t "${TMUX_PANE}" @status idle 2>/dev/null
  fi
  _tmux_status_start=0
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec _tmux_status_preexec
add-zsh-hook precmd _tmux_status_precmd
