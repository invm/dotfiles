insert-newline() { LBUFFER+=$'\n' }
zle -N insert-newline
bindkey '^[[27;2;13~' insert-newline
