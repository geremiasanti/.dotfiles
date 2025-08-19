# Dotfiles Bare Repo Setup

```sh
git clone --bare git@github.com:geremiasanti/.dotfiles.git $HOME/.dotfiles
echo "alias dotfiles='/usr/bin/git --git-dir=\$HOME/.dotfiles/ --work-tree=\$HOME'" >> ~/.bashrc
source ~/.bashrc
dotfiles checkout
dotfiles config --local status.showUntrackedFiles no
```

# Usage

Only files unignored in `.gitignore` are tracked.

Use `dotfiles` as a wrapper for git commands:
```sh
dotfiles status
dotfiles add .bashrc
dotfiles commit -m "Update bashrc"
```

# Dependencies (incomplete)

## Installing Picom (ibhagwan fork) on Ubuntu + i3

Steps to install the blur-capable fork of `picom` (ibhagwan) on Ubuntu 24.04 with the i3 window manager.

### 1. Remove default picom (optional)
```bash
sudo apt remove --purge picom
sudo apt autoremove --purge
```

### 2. Install build dependencies
```bash
sudo apt install -y meson ninja-build gcc make pkg-config \
  libxext-dev libxcb1-dev libxcb-damage0-dev libxcb-xfixes0-dev \
  libxcb-shape0-dev libxcb-render-util0-dev libxcb-render0-dev \
  libxcb-randr0-dev libxcb-composite0-dev libxcb-image0-dev \
  libxcb-present-dev libxcb-xinerama0-dev libxcb-glx0-dev \
  libpixman-1-dev libdbus-1-dev libconfig-dev libgl1-mesa-dev \
  libpcre2-dev libevdev-dev uthash-dev libev-dev libx11-xcb-dev \
  libpcre3-dev
```

### 3. Build and install 
```bash
git clone https://github.com/ibhagwan/picom.git
cd picom
meson setup --buildtype=release build
ninja -C build
sudo ninja -C build install
```
