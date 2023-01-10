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
brew cask install "font-hack-nerd-font"
brew cask install "font-open-sans"
brew cask install "font-ubuntu"


# Install powerline fonts
[ ! -d "./.tmp" ] && mkdir -p ./.tmp
git clone https://github.com/powerline/fonts.git --depth=1 ./.tmp/powerline-fonts
bash ./.tmp/powerline-fonts/install.sh
[ -d "./.tmp" ] && rm -rf ./.tmp

# Install all fonts in this folder.
cp -f $HOME/.dotfiles/fonts/* $HOME/Library/Fonts

echo ""
echo "Install fonts done!"
echo ""
