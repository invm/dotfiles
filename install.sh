#!/bin/sh
set -e

uname -a

# install brew
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# uninstall brew
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
is_mac=$(uname -a | grep -i "darwin" | wc -l)

if [ "$is_mac" -eq 0 ]; then
	eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

brew install zsh

command -v zsh | sudo tee -a /etc/shells
sudo chsh -s "$(command -v zsh)" "${USER}"

packages="stow wget tree htop tmux vim neovim
  eza fzf bat ripgrep zoxide xclip scc diff-so-fancy
  fd dog btop dust tldr lazydocker entr virtualenv
  zsh-syntax-highlighting zsh-completions zsh-autosuggestions
  lazygit jq yq gnu-sed
  "

export HOMEBREW_NO_AUTO_UPDATE=1
for package in $packages; do
	brew install "$package"
done

# install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# rust
curl https://sh.rustup.rs -sSf | sh -s -- -y

# node, n and pnpm
curl -L https://bit.ly/n-install | bash -s -- -y
curl -fsSL https://get.pnpm.io/install.sh | sh -

stow .

# configure lazygit to use diff-so-fancy
# https://github.com/jesseduffield/lazygit/blob/master/docs/Custom_Pagers.md
echo 'git:
  paging:
    colorArg: always
    pager: diff-so-fancy' >>~/.config/lazygit/config.yml


# oh-my-zsh completions, zoxide init and load custom zsh files
sed -i 's/source $ZSH\/oh-my-zsh.sh//' ~/.zshrc
echo '
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src
source $ZSH/oh-my-zsh.sh

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

if type brew &>/dev/null; then
  FPATH="$(brew --prefix)"/share/zsh-completions:$FPATH
  autoload -Uz compinit
  compinit
fi

source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# load zoxide
eval "$(zoxide init zsh)"

# load atuin
eval "$(atuin init zsh)"

# Load seperated config files
for conf in "$HOME/.config/zsh/"*.zsh; do
  source "${conf}"
done
unset conf

export EDITOR=nvim
' >>~/.zshrc

echo "Done! Restart your terminal."
