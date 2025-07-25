# Dotfiles Bare Repo

This repository manages my personal dotfiles using a bare Git repository

## Setup

```sh
git clone --bare git@github.com:geremiasanti/.dotfiles.git $HOME/.dotfiles
echo "alias dotfiles='/usr/bin/git --git-dir=\$HOME/.dotfiles/ --work-tree=\$HOME'" >> ~/.bashrc
source ~/.bashrc
dotfiles checkout
dotfiles config --local status.showUntrackedFiles no
```

## Usage

Only files unignored in `.gitignore` are tracked.

Use `dotfiles` as a wrapper for git commands:
```sh
dotfiles status
dotfiles add .bashrc
dotfiles commit -m "Update bashrc"
```
