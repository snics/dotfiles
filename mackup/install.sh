#!/usr/bin/env bash

echo "Install Mackup...."
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

brew install mackup

# Remove outdated versions from the cellar.
brew cleanup

cp -f $HOME/.dotfiles/mackup/.mackup.cfg $HOME/.mackup.cfg

echo ""
echo "Install Mackup done!"
echo ""
