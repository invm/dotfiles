export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
fpath+=${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-completions/src
[[ -z $HOMEBREW_PREFIX ]] && eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
FPATH="$HOMEBREW_PREFIX/share/zsh-completions:$FPATH"
DISABLE_AUTO_UPDATE=true
ZSH_DISABLE_COMPFIX=true
source $ZSH/oh-my-zsh.sh
[[ $TERM_PROGRAM == rex ]] && source /Applications/Ghostty.app/Contents/Resources/ghostty/shell-integration/zsh/ghostty-integration


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

# strix
export PATH=/Users/michael/.strix/bin:$PATH
