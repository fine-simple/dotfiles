# Uncomment for debugging
# set -x 

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

# WSL: strip Windows paths (/mnt/c/...) added by interop. Stat/readdir on drvfs
# is very slow, and compinit/completions scan every PATH dir on each shell.
# Fall back to `wslpath` etc. from an explicit Windows path if you ever need it.
if [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
  path=("${(@)path:#/mnt/*}")
fi

# Setup zinit
ZINIT_HOME="$HOME/.local/share/zinit/"

# Source zinit
source "$ZINIT_HOME/zinit.zsh"

# Add in zsh plugins 
# add wait before `lucid` to enable turbo mode (load after first prompt so panes/windows render instantly)
zinit lucid light-mode for zsh-users/zsh-autosuggestions
zinit lucid light-mode for zsh-users/zsh-syntax-highlighting
zinit lucid light-mode for zsh-users/zsh-completions
zinit lucid light-mode for Aloxaf/fzf-tab
# Add in snippets
zinit snippet OMZP::copyfile
zinit snippet OMZP::jsontools
zinit snippet OMZP::pip

# Load completions (only run the full, slower security check once per day;
# subsequent shells reuse the cached dump for a much faster compinit)
autoload -Uz compinit
_zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
if [[ -n ${_zcompdump}(#qN.mh+24) ]]; then
  compinit -d "${_zcompdump}"
else
  compinit -C -d "${_zcompdump}"
fi
unset _zcompdump
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

# Cache the generated init script so we don't spawn oh-my-posh on every shell/pane;
# it's only regenerated when the config file changes.
POSH_CONFIG="$HOME/.config/ohmyposh/powerlevel10k.json"
POSH_CACHE="$HOME/.cache/oh-my-posh-init.zsh"
if [[ ! -f "$POSH_CACHE" || "$POSH_CONFIG" -nt "$POSH_CACHE" ]]; then
  mkdir -p "${POSH_CACHE:h}"
  oh-my-posh init zsh --config "$POSH_CONFIG" > "$POSH_CACHE"
fi
source "$POSH_CACHE"

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
if [[ ! -d "$TPM_HOME" ]]; then
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
if [[ -f ~/.fzf.zsh ]]; then
  source ~/.fzf.zsh
elif [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
  source /usr/share/doc/fzf/examples/key-bindings.zsh
  source /usr/share/doc/fzf/examples/completion.zsh
fi

# Functions
source ~/.functions

# Aliases
source ~/.aliases


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

# fnm (lazy-loaded: avoid spawning the fnm binary on every pane/window unless
# node/npm/npx/fnm is actually used in that shell)
FNM_PATH="/home/tawfik/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  __fnm_lazy_load() {
    unfunction fnm node npm npx yarn pnpm 2>/dev/null
    eval "$(command fnm env --shell zsh)"
  }
  for __cmd in fnm node npm npx yarn pnpm; do
    eval "${__cmd}() { __fnm_lazy_load; ${__cmd} \"\$@\" }"
  done
  unset __cmd
fi

# bun completions
if [[ -s "/home/tawfik/.bun/_bun" ]]; then
  source "/home/tawfik/.bun/_bun"
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
fi

