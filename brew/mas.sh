#!/usr/bin/env bash

echo -e "\\n\\nInstall app store apps...."
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
# SnippetsLab
mas install 1006087419
# Medis reids clint for mac
mas install 1063631769

# Final Cut Pro
mas install 424389933
# Motion 5
mas install 434290957
# Compressor
mas install 424390742
# Logic Pro X
mas install 634148309
# GoodNotes 5
mas install 1444383602

echo ""
echo "Install app store apps done!"
echo ""
