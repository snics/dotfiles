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

# TODO: Set up NeoVim from the dotfiles as a symlink
git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1 && nvim
# TODO: Add my custemized settings the dotfiles
# TODO: Add Neovim as the default editor to all the shells


echo "Install Vim and NeoVim done!"
echo ""
