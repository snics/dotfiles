#!/usr/bin/env bash

echo -e "\\n\\nInstall python...."
echo ""

which -s brew
if [[ $? != 0 ]] ; then
    # Install Homebrew
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Make sure we’re using the latest Homebrew.
brew update
# Upgrade any already-installed formulae.
brew upgrade
brew cask upgrade

# Utils
brew install "miniconda"
brew install "pyenv"
brew install "jupyter"

# Remove outdated versions from the cellar.
brew cleanup

echo ""
echo "Install python done!"
echo ""
