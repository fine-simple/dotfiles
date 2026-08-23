# Setup fzf
# ---------
if [[ ! "$PATH" == */home/tawfik/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/tawfik/.fzf/bin"
fi

source <(fzf --zsh)
