#!/bin/bash

set -euxo

export PATH=$PATH:~/.local/bin

install_pkg() {
  local pkg="$1"
  local cmd="${2:-$1}"  # Use second arg as command name, or default to package name
  
  # Check if command already exists
  if command -v "$cmd" &>/dev/null; then
    return 0
  fi
  
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

install_pkg stow
install_pkg zsh
install_pkg tmux
install_pkg pipx
install_pkg neovim
install_pkg unzip

if ! command -v oh-my-posh >/dev/null; then
  curl -s https://ohmyposh.dev/install.sh | bash -s
fi

install_pkg fortune
install_pkg cowsay
install_pkg fzf
install_pkg python3
install_pkg python3-pip pip3

if ! command -v fnm >/dev/null; then
  curl -fsSL https://fnm.vercel.app/install | bash
fi

if ! command -v colout >/dev/null; then
  pipx install colout
fi

if ! command -v fuck >/dev/null; then
  pipx install thefuck
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

if ! command -v bat >/dev/null; then
  cargo install bat --locked
fi

# Install npm-based tools (now that nodejs is installed)
if ! command -v bw >/dev/null; then
  if command -v npm >/dev/null; then
    npm install -g @bitwarden/cli
  else
    echo "⚠️  npm not found, skipping Bitwarden CLI installation"
  fi
fi

ZINIT_HOME="$HOME/.local/share/zinit/"
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi


echo 'Adding missing files...'

if [ -n "$(grep -i microsoft /proc/version)" -a -f ~/.wsl-init ]; then
  [ ! -f ~/.wsl-init ] && touch ~/.wsl-init
fi

echo 'Running Stow...'

stow --adopt .
git restore .
stow .

# Set zsh as default shell if not already
if [ "$SHELL" != "$(which zsh)" ]; then
  echo "Setting zsh as default shell..."
  chsh -s "$(which zsh)"
  echo "✓ Zsh set as default shell. Please log out and back in, or run 'exec zsh' to start using it."
fi

echo ""
echo "✓ Dotfiles setup complete!"
echo "  To apply all changes, either:"
echo "  1. Log out and log back in"
echo "  2. Run: exec zsh"

