# Dotfiles

## Install script

Run `(sudo on macos) ./install/brew.sh` to istall Brew, Zsh and oh-my-zsh.

Run `./install/packages.sh` to install packages.

Run `./install/wezterm.sh` to istall Wezterm on GUI environment.

Run `stow .` from here.

Macos unsafe dir issue:
```
compaudit | xargs -I{} sudo chown -R $(whoami) "{}"
compaudit | xargs -I{} sudo chmod -R go-w "{}"

```
