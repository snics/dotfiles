#!/usr/bin/env bash

echo "Install fonts...."
echo ""

which -s brew
if [[ $? != 0 ]] ; then
    # Install Homebrew
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Install command-line tools using Homebrew.
brew tap "homebrew/cask"
brew tap "homebrew/cask-drivers"
brew tap "homebrew/cask-fonts"
brew tap "homebrew/cask-versions"

# fonts
brew cask install "font-fira-code"
brew cask install "font-hack"
brew cask install "font-inconsolata"
brew cask install "font-fira-code"
brew cask install "font-jetbrains-mono"
brew cask install "font-cascadia-mono"

git clone https://github.com/powerline/fonts.git --depth=1 ./powerline-fonts
bash ./powerline-fonts/install.sh
rm -rf ./powerline-fonts

cp -f $HOME/.dotfiles/fonts/* $HOME/Library/Fonts

echo ""
echo "Install fonts done!"
echo ""
