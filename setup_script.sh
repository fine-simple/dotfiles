#!/bin/bash

set -euo pipefail

case ":$PATH:" in
*":$HOME/.local/bin:"*) ;;
*) export PATH="$PATH:$HOME/.local/bin" ;;
esac

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
install_pkg git-lfs
install_pkg inotify-tools
install_pkg xclip

if ! command -v oh-my-posh >/dev/null; then
  curl -s https://ohmyposh.dev/install.sh | bash -s
fi

if ! command -v fzf >/dev/null; then
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install
fi

install_pkg python3
install_pkg python3-pip pip3

if ! python3 -c 'import groq' &>/dev/null; then
  python3 -m pip install --user groq 2>/dev/null ||
    python3 -m pip install --user --break-system-packages groq
fi

if ! command -v fnm >/dev/null; then
  curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
fi

if [ -d "$HOME/.local/share/fnm" ]; then
  export PATH="$HOME/.local/share/fnm:$PATH"
fi

if command -v fnm >/dev/null; then
  eval "$(fnm env)"
  if ! command -v node >/dev/null; then
    fnm install --lts
    fnm default lts-latest
    eval "$(fnm env)"
  fi
fi

if ! command -v cargo >/dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --no-modify-path -y
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

if ! command -v delta >/dev/null; then
  cargo install git-delta --locked
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

TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
  mkdir -p "$(dirname $TPM_DIR)"
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

git lfs install


echo 'Running Stow...'

stow --adopt .
git restore .
stow .

# Create pre/post zshrc extension files if they don't exist
for ext_file in ~/.zshrc.pre.ext ~/.zshrc.post.ext; do
  if [ ! -f "$ext_file" ]; then
    touch "$ext_file"
    echo "✓ Created $ext_file"
  fi
done

# Set zsh as default shell if not already
zsh_path="$(command -v zsh)"
current_shell="$(getent passwd "${USER:-$(id -un)}" | cut -d: -f7)"

if [ "$current_shell" != "$zsh_path" ]; then
  echo "Setting zsh as default shell..."
  chsh -s "$zsh_path"
  echo "✓ Zsh set as default shell. Please log out and back in, or run 'exec zsh' to start using it."
fi

echo ""
echo "✓ Dotfiles setup complete!"
echo "  To apply all changes, either:"
echo "  1. Log out and log back in"
echo "  2. Run: exec zsh"

