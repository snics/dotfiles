#!/usr/bin/env bash

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Install mas (Mac App Store command line interface)
brew install mas

# Update all applications
mas upgrade

#############################################################
# Install Apps                                              #
#############################################################

# Xcode
mas install 497799835
# Spark Mail App
mas install 1176895641
# Todoist
mas install 585829637
# Magnet
mas install 441258766
