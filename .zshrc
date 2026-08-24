# 1. Environment & Path Setup
[[ -f ~/.zshrc.pre.ext ]] && source ~/.zshrc.pre.ext

export EDITOR='nvim'
export VISUAL='nvim'
export PATH=~/bin:/usr/local/bin:~/.local/bin:~/.scripts:~/.fzf/bin:$PATH
export PATH=$PATH:/usr/local/go/bin

# WSL: strip slow Windows paths
if [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
  path=("${(@)path:#/mnt/*}")
fi

# 2. Tmux Auto-Start (Interactive only)
if [[ -z "${TMUX:-}" && -t 1 && -z "${ZSH_TMUX_STARTED:-}" ]]; then
  export ZSH_TMUX_STARTED=1
  FIRST_UNATTACHED="$(tmux ls -F '#{session_name}|#{?session_attached,attached,not attached}' 2>/dev/null | grep 'not attached$' | tail -n 1 | cut -d '|' -f1)"
  if [[ -n "$FIRST_UNATTACHED" ]]; then
    exec tmux attach -t "$FIRST_UNATTACHED" 2> /dev/null
  else
    exec tmux new
  fi
fi

# 3. Zinit Setup
ZINIT_HOME="$HOME/.local/share/zinit/"
source "$ZINIT_HOME/zinit.zsh"

# 4. Optimized Completions (Fixes the 1.5s lag)
setopt extendedglob
autoload -Uz compinit
_zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
# Only run full security check if cache is older than 24h
if [[ -n ${_zcompdump}(#qN.mh+24) ]]; then
  compinit -d "${_zcompdump}"
else
  compinit -C -d "${_zcompdump}"
fi
unset _zcompdump
zinit cdreplay -q

# 5. Plugins (Turbo Mode)
zinit lucid light-mode for zsh-users/zsh-autosuggestions
zinit lucid light-mode for zsh-users/zsh-syntax-highlighting
zinit lucid light-mode for zsh-users/zsh-completions
zinit lucid light-mode for Aloxaf/fzf-tab

zinit snippet OMZP::copyfile
zinit snippet OMZP::jsontools
zinit snippet OMZP::pip

# 6. History & Options
HISTSIZE=2000
HISTFILE=~/.zsh_history
SAVEHIST=1000000
setopt appendhistory
setopt sharehistory
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_save_no_dups
setopt hist_ignore_space

# 7. Completion & Plugin Styling
zstyle ":completion:*" matcher-list "m:{a-z}={A-Za-z}"
zstyle ":completion:*" list-colors "${(s.:.)LS_COLORS}"
zstyle ":completion:*" menu no
zstyle ":fzf-tab:complete:cd:*" fzf-preview 'ls --color $realpath'
zstyle ":fzf-tab:complete:__zoxide_z:*" fzf-preview 'ls --color $realpath'
zstyle :omz:plugins:ssh-agent lifetime 24h

# 8. Prompt (Cached oh-my-posh)
POSH_CONFIG="$HOME/.config/ohmyposh/powerlevel10k.json"
POSH_CACHE="$HOME/.cache/oh-my-posh-init.zsh"
if [[ ! -f "$POSH_CACHE" || "$POSH_CONFIG" -nt "$POSH_CACHE" ]]; then
  mkdir -p "${POSH_CACHE:h}"
  oh-my-posh init zsh --config "$POSH_CONFIG" > "$POSH_CACHE"
fi
source "$POSH_CACHE"

# 9. Keybindings (CRITICAL: bindkey -e must come BEFORE custom bindings)
bindkey -e
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
bindkey "^p" history-search-backward
bindkey "^n" history-search-forward
bindkey -s "^[^L" '^Uclear^M'
bindkey '^F' fzf-history-widget-all

# 10. Edit Command Line (The Fix)
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line
bindkey -M vicmd '^X^E' edit-command-line
bindkey -M viins '^X^E' edit-command-line

# 11. External Tools & Scripts
if [[ -f ~/.fzf.zsh ]]; then
  source ~/.fzf.zsh
elif [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
  source /usr/share/doc/fzf/examples/key-bindings.zsh
  source /usr/share/doc/fzf/examples/completion.zsh
fi

[[ -f ~/.functions ]] && source ~/.functions
[[ -f ~/.aliases ]] && source ~/.aliases
[[ -f ~/.zshrc.post.ext ]] && source ~/.zshrc.post.ext
[[ -f ~/.secrets ]] && source ~/.secrets

eval "$(zoxide init --cmd cd zsh)"

# 12. Lazy-loaded Version Managers
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

if [[ -s "/home/tawfik/.bun/_bun" ]]; then
  source "/home/tawfik/.bun/_bun"
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
fi
