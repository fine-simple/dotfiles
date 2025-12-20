#!/bin/bash

set -euo

install_pkg() {
  local pkg="$1"
  if command -v apt &>/dev/null; then
    sudo apt update && sudo apt install -y "$pkg"
  elif command -v dnf &>/dev/null; then
    sudo dnf install -y "$pkg"
  elif command -v pacman &>/dev/null; then
    sudo pacman -Sy --noconfirm "$pkg"
  elif command -v zypper &>/dev/null; then
    sudo zypper install -y "$pkg"
  elif command -v apk &>/dev/null; then
    sudo apk add "$pkg"
  else
    echo "❌ No known package manager found to install $pkg" >&2
    exit 1
  fi
}

echo 'Installing necessary packages...'

if ! command -v stow >/dev/null; then
  install_pkg stow
fi

if ! command -v zsh >/dev/null; then
  install_pkg zsh
fi

if ! command -v tmux >/dev/null; then
  install_pkg tmux
fi

# Install necessary programs
if ! command -v unzip >/dev/null; then
  sudo apt install unzip
fi

if ! command -v oh-my-posh >/dev/null; then
  curl -s https://ohmyposh.dev/install.sh | bash -s
fi

if ! command -v fortune >/dev/null; then
  install_pkg fortune
fi

if ! command -v cowsay >/dev/null; then
  install_pkg cowsay
fi

if ! command -v fzf >/dev/null; then
  install_pkg fzf
fi

if ! command -v python3 >/dev/null; then
  install_pkg python3
fi

if ! command -v pip3 >/dev/null; then
  install_pkg python3-pip
fi

if ! command -v colout >/dev/null; then
  pip3 install --user colout
fi

if ! command -v fuck >/dev/null; then
  pip3 install thefuck
fi

if ! command -v cargo >/dev/null; then
  curl https://sh.rustup.rs -sSf | sh
  source ~/.cargo/env
fi

if ! command -v zoxide >/dev/null; then
  cargo install zoxide --locked
fi

if ! command -v eza >/dev/null; then
  cargo install eza --locked
fi

if ! command -v tmuxinator >/dev/null; then
  gem install tmuxinator
fi

ZINIT_HOME="$HOME/.local/share/zinit/"
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi


echo 'Adding missing files...'

[ -f .zshrc.ext ] || touch .zshrc.ext

if [ -n "$(grep -i microsoft /proc/version)" -a -f ~/.wsl-init ]; then
  [ ! -f ~/.wsl-init ] && touch ~/.wsl-init

  cat >> .zshrc.ext <<EOF

sudo wget https://raw.githubusercontent.com/tmuxinator/tmuxinator/master/completion/tmuxinator.zsh -O /usr/local/share/zsh/site-functions/_tmuxinator

# load wsl env variables
source ~/.wsl-init

EOF
fi

if [ -f "$HOME/.cargo/env" ]; then
  cat >> .zshrc.ext <<EOF

# cargo
source "$HOME/.cargo/env"

EOF
fi

if command -v thefuck >/dev/null; then
  cat >> .zshrc.ext <<EOF
eval $(thefuck --alias f)
EOF
fi

echo 'Running Stow...'

stow .

if [ -z "${ZSH_VERSION:-}" ]; then
  echo "Making zsh the default shell..."
  chsh -s "$(which zsh)"
fi

exec zsh

