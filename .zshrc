export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
fpath+=${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-completions/src
source $ZSH/oh-my-zsh.sh

eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
FPATH="$HOMEBREW_PREFIX/share/zsh-completions:$FPATH"
autoload -Uz compinit && compinit

source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
eval "$(zoxide init zsh)"

for conf in "$HOME/.config/zsh/"*.sh; do source "$conf"; done
unset conf

export EDITOR=nvim
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export PATH="$HOME/.local/bin:$PATH"

export N_PREFIX="$HOME/n"
export PATH="$N_PREFIX/bin:$PATH"
export PNPM_HOME="$HOME/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

# machine-specific, not in repo
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
