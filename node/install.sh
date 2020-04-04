#!/usr/bin/env bash

echo "======================================================"
echo "Welcome to git dotfiles Installation."
echo "======================================================"

which -s brew
if [[ $? != 0 ]] ; then
    # Install Homebrew
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Make sure we’re using the latest Homebrew.
brew update
# Upgrade any already-installed formulae.
brew upgrade

brew install node

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash

echo "======================================================"
echo "git config install done...."
echo "======================================================"
