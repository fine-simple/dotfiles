# My dotfiles

This repo contains the dotfiles for my system

## Requirements

Ensure you have the required packages by running the following

```sh
sudo apt install git stow
```

## Installation

First, check out the dotfiles repo in your $HOME directory using git

```sh
cd ~
git clone git@github.com:fine-simple/dotfiles.git
cd dotfiles
```

then use GNU stow to create symlinks

```sh
stow .
```

## Credit

This repo was made from this [tutorial](https://www.youtube.com/watch?v=y6XCebnB9gs)
