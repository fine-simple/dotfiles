# skip the unconditional full compinit that /etc/zsh/zshrc runs on Ubuntu;
# our own .zshrc already runs a cached compinit
skip_global_compinit=1

. "$HOME/.cargo/env"
