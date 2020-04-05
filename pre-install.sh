#!/usr/bin/env bash

if [ ! -d "$HOME/.dotfiles" ]; then
    echo "Installing Nico's Dotfiles for the first time"
    git clone --depth=1 https://github.com/snics/dotfiles.git "$HOME/.dotfiles"
    cd "$HOME/.dotfiles"
else
    echo "Nico's Dotfiles is already installed"
fi
