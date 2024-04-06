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

brew tap wez/wezterm-linuxbrew
brew install wezterm

brew install zsh

command -v zsh | sudo tee -a /etc/shells
sudo chsh -s "$(command -v zsh)" "${USER}"

echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zshrc

# # install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

sudo update-alternatives --config x-terminal-emulator

echo "Wezterm, Brew and zsh were installed, restart your terminal."
