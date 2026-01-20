#!/bin/sh

is_mac=$(uname -a | grep -i "darwin" | wc -l)

if [ "$is_mac" -eq 0 ]; then
	eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
	brew tap wez/wezterm-linuxbrew
	brew install wezterm
else
	eval "$(/opt/homebrew/bin/brew shellenv)"
	brew install --cask wezterm
fi

sudo update-alternatives --config x-terminal-emulator

echo "Brew and zsh were installed, restart your terminal."
