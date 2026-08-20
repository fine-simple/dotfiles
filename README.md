# Dotfiles

A comprehensive Unix/Linux dotfiles configuration focused on Zsh, Tmux, and modern CLI tooling.

## Overview

This repository contains my personal dotfiles and configuration for a modern terminal-based development environment. It includes configurations for:

- **Shell**: Zsh with custom aliases, functions, and plugins
- **Terminal Multiplexer**: Tmux with sensible defaults and plugins
- **Editor**: Neovim configuration
- **Git**: Custom aliases and workflow enhancements
- **CLI Tools**: Modern replacements for traditional Unix tools (eza, zoxide, fzf)
- **Prompt**: Oh My Posh theming

## Features

### Shell (Zsh)
- **Plugin Manager**: Zinit for fast plugin loading
- **Plugins**: 
  - `zsh-autosuggestions` - command suggestions based on history
  - `zsh-syntax-highlighting` - real-time command syntax highlighting
  - `zsh-completions` - additional completion definitions
  - `fzf-tab` - fuzzy search for tab completions
  - `zsh-nvm` - Node Version Manager integration
- **Smart history**: 10,000 entries with duplicate removal and persistent across sessions
- **Fuzzy finder**: FZF integration for file/history search
- **Auto-tmux**: Automatically starts or attaches to tmux on shell launch

### Terminal (Tmux)
- Mouse support enabled
- Vi-mode keybindings
- Custom prefix: `Ctrl+a` (replaces default `Ctrl+b`)
- Split panes with `|` and `-`
- Plugins via TPM:
  - `tmux-resurrect` - save/restore tmux sessions
  - `tmux-continuum` - automatic session saving
  - `tmux-yank` - copy to system clipboard
  - `catppuccin/tmux` - catppuccin theme
  - `extrakto` - fuzzy find and copy text from pane

### Git Configuration
- Custom aliases:
  - `git lol` - pretty graph log
  - `git fire` - emergency commit and push
  - `git staash` - stash including untracked files
  - `git bb` - better branch listing
  - `git count-lines` - count lines of code by author
  - `git rm-branch` - delete local and remote branch
- Auto-setup remote branches on push
- Rerere enabled for conflict resolution
- Work/personal git config separation via conditional includes

### Modern CLI Tools
- **eza**: Modern replacement for `ls` with better colors and icons
- **zoxide**: Smart directory jumper (replaces `cd`)
- **fzf**: Fuzzy finder for files, history, and more
- **tmuxinator**: Tmux session manager

### Custom Scripts
Located in `.scripts/`:
- `better-git-branch` - Enhanced git branch management
- `git-fire` - Emergency git commit and push
- `muxf` - Fuzzy tmux session selector
- `watch_files` - File watching utility

## Requirements

The automated setup script supports multiple Linux distributions:
- **Debian/Ubuntu**: apt
- **Fedora**: dnf
- **Arch Linux**: pacman
- **openSUSE**: zypper
- **Alpine**: apk

Minimum requirements:
- Git
- GNU Stow
- Bash (for running setup script)

## Installation

### Automated Installation (Recommended)

1. Clone this repository to your home directory:
```bash
cd ~
git clone git@github.com:fine-simple/dotfiles.git
cd dotfiles
```

2. Run the automated setup script:
```bash
chmod +x setup_script.sh
./setup_script.sh
```

The script will:
- Detect your package manager and install required packages
- Install core tools: stow, zsh, tmux, fzf, python3
- Install modern CLI tools: eza, zoxide, oh-my-posh
- Install development tools: cargo (Rust), nvm (Node.js)
- Set up Zinit plugin manager
- Configure additional settings for WSL if detected
- Create symlinks using GNU Stow
- Set Zsh as your default shell

### Manual Installation

If you prefer manual installation:

1. Install required packages:
```bash
# Debian/Ubuntu
sudo apt install git stow zsh tmux fzf python3 python3-pip

# Fedora
sudo dnf install git stow zsh tmux fzf python3 python3-pip

# Arch Linux
sudo pacman -S git stow zsh tmux fzf python python-pip
```

2. Clone the repository:
```bash
cd ~
git clone git@github.com:fine-simple/dotfiles.git
cd dotfiles
```

3. Create symlinks with GNU Stow:
```bash
stow .
```

4. Install additional tools manually:
```bash
# Oh My Posh
curl -s https://ohmyposh.dev/install.sh | bash -s

# Rust and Cargo
curl https://sh.rustup.rs -sSf | sh

# Eza and Zoxide (requires cargo)
cargo install eza zoxide --locked

# Zinit
git clone https://github.com/zdharma-continuum/zinit.git ~/.local/share/zinit
```

5. Change default shell to Zsh:
```bash
chsh -s $(which zsh)
```

6. Log out and log back in, or start a new Zsh session:
```bash
exec zsh
```

## Configuration Files

### Main Configuration
- `.zshrc` - Zsh configuration with plugins and settings
- `.tmux.conf` - Tmux configuration
- `.gitconfig` - Git global configuration
- `.aliases` - Shell aliases
- `.functions` - Custom shell functions

### Application Configs
- `.config/nvim/init.vim` - Neovim configuration
- `.config/ohmyposh/` - Oh My Posh themes
- `.config/wezterm/` - WezTerm terminal emulator config

### Extension Points
- `.zshrc.pre.ext` - Sourced before main Zsh config (optional, not tracked)
- `.zshrc.post.ext` - Sourced after main Zsh config (optional, not tracked)
- `.wsl-init` - WSL-specific environment variables (optional, not tracked)

## Key Bindings

### Zsh
- `Ctrl+p` / `Ctrl+n` - Navigate command history
- `Ctrl+[` `Ctrl+L` - Clear screen
- `Ctrl+→` / `Ctrl+←` - Move forward/backward by word

### Tmux
- `Ctrl+a` - Prefix key (instead of default `Ctrl+b`)
- `Ctrl+a |` - Split pane vertically
- `Ctrl+a -` - Split pane horizontally
- `Ctrl+a Ctrl+a` - Cycle through panes

## Customization

### Adding Personal Configurations

To add machine-specific or private configurations without modifying tracked files:

1. Create `.zshrc.pre.ext` for pre-initialization setup
2. Create `.zshrc.post.ext` for post-initialization overrides
3. For work-specific git config, create `~/.work/.gitconfig`

### Work/Personal Git Separation

The git configuration includes conditional includes. Any repository under `~/work/` will use the config from `~/.work/.gitconfig`.

## WSL Support

The setup script automatically detects Windows Subsystem for Linux and applies WSL-specific configurations.

## Uninstalling

To remove the symlinks created by Stow:

```bash
cd ~/dotfiles
stow -D .
```

This will remove all symlinks but preserve the dotfiles directory.

## Updating

To update your dotfiles:

```bash
cd ~/dotfiles
git pull
stow -R .  # Restow to pick up any new files
```

## Credits

- Initial structure inspired by this [tutorial](https://www.youtube.com/watch?v=y6XCebnB9gs)
- Tmux configuration influenced by community best practices
- Oh My Posh themes from [Oh My Posh](https://ohmyposh.dev/)
- Catppuccin color scheme for Tmux

## License

Feel free to use and modify these dotfiles for your personal use.
