#!/bin/sh
# macOS only. Run from repo root.
set -e

command -v brew >/dev/null || NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(brew shellenv 2>/dev/null || /opt/homebrew/bin/brew shellenv)"

brew bundle --file="$(dirname "$0")/Brewfile"

zsh_path="$(brew --prefix)/bin/zsh"
grep -q "$zsh_path" /etc/shells || echo "$zsh_path" | sudo tee -a /etc/shells
[ "$SHELL" = "$zsh_path" ] || chsh -s "$zsh_path"

[ -d ~/.oh-my-zsh ] || sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
[ -d ~/.tmux/plugins/tpm ] || git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

command -v cargo >/dev/null || curl https://sh.rustup.rs -sSf | sh -s -- -y
command -v n >/dev/null || curl -L https://bit.ly/n-install | bash -s -- -y
command -v pnpm >/dev/null || curl -fsSL https://get.pnpm.io/install.sh | sh -

stow -d "$(dirname "$0")" -t ~ .
echo "Done. Restart terminal."
