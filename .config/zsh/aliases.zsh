alias q=exit
alias v=nvim
alias cat=bat
alias grep=rg
alias ls=eza
alias pn=pnpm
alias t=tmux
alias cl=clear
alias k=kubectl
alias f="kubectl logs -f"
alias d="kubectl describe"
alias wpod="kubectl get pods -A --no-headers | fzf | awk '{ print \$2 }' | xargs -I {} sh -c 'watch \"kubectl get pods -A | grep {} \"'"
alias lpod="kubectl get pods --no-headers | fzf | awk '{ print \$1 }' | xargs -I {} sh -c 'kubectl logs -f {}'"

source <(fzf --zsh)
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt appendhistory
