#!/usr/bin/env bash

# Install command-line tools using Homebrew.
which -s brew
if [[ $? != 0 ]] ; then
    # Install Homebrew
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

which -s stow
if [[ $? != 0 ]] ; then
    # Install GNU Stow
    echo "Installing GNU Stow..."
    brew install stow;
fi

# Install Homebrew Bundle
echo "Installing Homebrew Bundle..."
stow brew;
brew bundle install --file=~/Brewfile;