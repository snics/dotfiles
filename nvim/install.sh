#!/usr/bin/env bash

DOTFILES=$HOME/.dotfiles

echo -e "\\n\\nInstall Vim and NeoVim...."
echo ""


# Install command-line tools using Homebrew.
which -s brew
if [[ $? != 0 ]] ; then
    # Install Homebrew
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Make sure we’re using the latest Homebrew.
brew update
# Upgrade any already-installed formulae.
brew upgrade

brew install git
brew install neovim

git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1 && nvim


echo "Install Vim and NeoVim done!"
echo ""
