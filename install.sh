#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE}")";

git pull origin master;

function doIt() {
    source ./_install/brew.sh;

    read -p "Would you like to put on my Mac Dock (y/n) " -n 1;
    echo "";
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        source ./macOS/dock.sh;
    fi;

    read -p "Do you want to use my zsh and oh-my-zsh settings? (y/n) " -n 1;
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        source ./_install/zsh.sh
    fi;

    read -p "Do you want to use Golang? (y/n) " -n 1;
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        source ./_install/golang.sh
    fi;

    read -p "Do you want to use Rust? (y/n) " -n 1;
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        source ./_install/rust.sh
    fi;

    read -p "Do you want to use asdf? (y/n) " -n 1;
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        source ./asdf/plugins.sh;
    fi;

    read -p "Would you like to use Mackup? (Keep your application settings in sync (OS X/Linux). https://github.com/lra/mackup) (y/n)" -n 1;
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        source ./_install/mackup.sh
    fi;

    read -p "Do you want to use Vim and NeoVim? (y/n) " -n 1;
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        source ./_install/nvim.sh
    fi;

    read -p "Do you want to have my Development/Project folder structure? (y/n) " -n 1;
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        source ./macOS/project-folder-structure.sh
    fi;

    source ./_install/git.sh

    source ./macOS/settings.sh;

    echo ""
    echo "Set your user tokens as environment variables, such as ~/.secrets"
    echo "See the README for examples."

    read -p "Do you want to restart your Mac (This is recommended now)? (y/n) " -n 1;
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo reboot
    fi;
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
    doIt;
else
    read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
    echo "";
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        doIt;
    fi;
fi;
unset doIt;
