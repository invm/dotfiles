# Dotfiles

macOS. Run `./install.sh` from repo root. Installs brew, packages from `Brewfile`, zsh, oh-my-zsh, tpm, stows configs.

Machine-specific shell config goes in `~/.zshrc.local` (gitignored).

Insecure dir warning on macOS:
```
compaudit | xargs -I{} sudo chown -R $(whoami) "{}"
compaudit | xargs -I{} sudo chmod -R go-w "{}"
```
