# Setup fzf
# ---------
if [[ ! "$PATH" == */home/ahmtaw9k/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/ahmtaw9k/.fzf/bin"
fi

source <(fzf --zsh)
