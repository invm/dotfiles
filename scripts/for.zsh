# add to .zshrc

# After plugins
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src

# load zoxide
eval "$(zoxide init zsh)"

# Load seperated config files
for conf in "$HOME/.config/zsh/"*.zsh; do
  source "${conf}"
done
unset conf
