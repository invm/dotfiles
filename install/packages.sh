#!/bin/sh
set -e

packages="stow wget tree htop tmux vim neovim
  eza fzf bat ripgrep zoxide xclip scc diff-so-fancy
  fd btop dust tldr lazydocker entr virtualenv
  zsh-syntax-highlighting zsh-completions zsh-autosuggestions
  lazygit jq yq gnu-sed
  "

export HOMEBREW_NO_AUTO_UPDATE=1
for package in $packages; do
	brew install "$package"
done

# tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# rust
curl https://sh.rustup.rs -sSf | sh -s -- -y

# node, n and pnpm
curl -L https://bit.ly/n-install | bash -s -- -y
curl -fsSL https://get.pnpm.io/install.sh | sh -

stow .

# oh-my-zsh completions, zoxide init and load custom zsh files
sed -i 's/source $ZSH\/oh-my-zsh.sh//' ~/.zshrc
echo '
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src
source $ZSH/oh-my-zsh.sh

if type brew &>/dev/null; then
  FPATH="$(brew --prefix)"/share/zsh-completions:$FPATH
  autoload -Uz compinit
  compinit
fi

source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# load zoxide
eval "$(zoxide init zsh)"

# Load seperated config files
for conf in "$HOME/.config/zsh/"*.sh; do
  source "${conf}"
done
unset conf

export EDITOR=nvim
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
' >>~/.zshrc

echo "Done! Restart your terminal."
