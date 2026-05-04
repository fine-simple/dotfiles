# set -x # Uncomment for debugging

# env specific pre setup
[[ -f ~/.zshrc.pre.ext ]] && source ~/.zshrc.pre.ext

# Start tmux only if:
# - not inside tmux
# - it's an interactive shell
# - there's no command passed to the shell
if [[ -z "${TMUX:-}" && -t 1 && -z "${ZSH_TMUX_STARTED:-}" ]]; then
  export ZSH_TMUX_STARTED=1
  FIRST_UNATTACHED="$(tmux ls -F '#{session_name}|#{?session_attached,attached,not attached}' 2>/dev/null | grep 'not attached$' | tail -n 1 | cut -d '|' -f1)"
  if [[ -n "$FIRST_UNATTACHED" ]]; then
    exec tmux attach -t "$FIRST_UNATTACHED" 2> /dev/null
  else
    exec tmux new
  fi
fi

# configure PATH
export PATH=~/bin:/usr/local/bin:~/.local/bin:~/.scripts:~/.fzf/bin:$PATH
export PATH=$PATH:/usr/local/go/bin

# Setup zinit
ZINIT_HOME="$HOME/.local/share/zinit/"

# NVM setup
export NVM_COMPLETION=true
export NVM_SYMLINK_CURRENT="true"

# Source zinit
source "$ZINIT_HOME/zinit.zsh"

# Add in zsh plugins
zinit lucid light-mode for zsh-users/zsh-autosuggestions
zinit lucid light-mode for zsh-users/zsh-syntax-highlighting
zinit wait lucid light-mode for zsh-users/zsh-completions
zinit wait lucid light-mode for Aloxaf/fzf-tab
zinit wait lucid light-mode for lukechilds/zsh-nvm
# Add in snippets
zinit snippet OMZP::copyfile
zinit snippet OMZP::jsontools
zinit snippet OMZP::pip

# Load completions
autoload -Uz compinit && compinit
zinit cdreplay -q

# Load edit command
autoload edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

# Completion styling
zstyle ":completion:*" matcher-list "m:{a-z}={A-Za-z}"
zstyle ":completion:*" list-colors "${(s.:.)LS_COLORS}"
zstyle ":completion:*" menu no
zstyle ":fzf-tab:complete:cd:*" fzf-preview 'ls --color $realpath'
zstyle ":fzf-tab:complete:__zoxide_z:*" fzf-preview 'ls --color $realpath'
zstyle :omz:plugins:ssh-agent lifetime 24h

eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/powerlevel10k.json)"

# History
HISTSIZE=2000
HISTFILE=~/.zsh_history
SAVEHIST=1000000
setopt appendhistory
setopt sharehistory
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_save_no_dups
setopt hist_ignore_space

# install tpm
TPM_HOME="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_HOME" ]; then
  git clone https://github.com/tmux-plugins/tpm "$TPM_HOME"
fi

# Keybindings
bindkey -e
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
bindkey "^p" history-search-backward
bindkey "^n" history-search-forward
bindkey -s "^[^L" '^Uclear^M'

# Setup fzf key bindings and fuzzy completion
# This enables Ctrl+R for fuzzy history search
if [ -f ~/.fzf.zsh ]; then
  source ~/.fzf.zsh
elif [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]; then
  source /usr/share/doc/fzf/examples/key-bindings.zsh
  source /usr/share/doc/fzf/examples/completion.zsh
fi

# Functions
source ~/.functions

# cargo
source ~/.cargo/env

# Aliases
source ~/.aliases

# Hello Message
if [ -z "$TMUX" -o "$(tmux list-windows 2>/dev/null | grep '(active)' | cut -d':' -f1)" = '1' -a "$(tmux list-panes 2> /dev/null | grep '(active)' | cut -d':' -f1)" = '1' ]; then
  fortune -as | cowsay -pnf tux | colout ' [^/|\\]+ ' blue
fi

# Use fzf to search the actual history file instead of just memory
zle -N fzf-history-widget-all
bindkey '^F' fzf-history-widget-all

# Setup zoxide
eval "$(zoxide init --cmd cd zsh)"

# Global Vars
export EDITOR='nvim'
export VISUAL=$EDITOR

# env specific post setup
[[ -f ~/.zshrc.post.ext ]] && source ~/.zshrc.post.ext

# export secrets
[[ -f ~/.secrets ]] && source ~/.secrets
