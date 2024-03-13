#!/bin/sh
set -e

uname -a

# install brew
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# uninstall brew
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"

(
	echo
	echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
) >>/home/mike/.zshrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

brew install zsh

command -v zsh | sudo tee -a /etc/shells
sudo chsh -s "$(command -v zsh)" "${USER}"

packages="stow wget tree htop tmux vim neovim
  eza fzf bat ripgrep zoxide xclip scc diff-so-fancy
  fd dog atuin btop dust tldr lazydocker entr virtualenv
  zsh-syntax-highlighting zsh-completions zsh-autosuggestions
  "

for package in $packages; do
	brew install "$package"
done

# install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# configure zsh plugins
# https://formulae.brew.sh/formula/zsh-completions
echo 'if type brew &>/dev/null; then
  FPATH="$(brew --prefix)"/share/zsh-completions:$FPATH
  autoload -Uz compinit
  compinit
fi' >>~/.zshrc
# https://formulae.brew.sh/formula/zsh-autosuggestions
echo 'source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh' >>~/.zshrc
# https://formulae.brew.sh/formula/zsh-syntax-highlighting
echo 'source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' >>~/.zshrc

# tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# node, n and pnpm
curl -L https://bit.ly/n-install | bash
curl -fsSL https://get.pnpm.io/install.sh | sh -

stow .

# configure lazygit to use diff-so-fancy
# https://github.com/jesseduffield/lazygit/blob/master/docs/Custom_Pagers.md

echo "Done! Please restart your terminal."
