#!/usr/bin/env bash

echo "======================================================"
echo "Welcome to oh-my-zsh and zs dotfiles Installation."
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

brew tap homebrew/command-not-found

brew install zsh
brew install zsh-completions
brew install zsh-autosuggestions
brew install fasd

sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

wget https://raw.githubusercontent.com/caiogondim/bullet-train-oh-my-zsh-theme/master/bullet-train.zsh-theme -O $HOME/.oh-my-zsh/custom/themes/bullet-train.zsh-theme
cp -f $HOME/.dotfiles/zsh/plugins/* $HOME/.oh-my-zsh/custom/plugins

cp -f $HOME/.dotfiles/zsh/.zshrc ~/.zshrc


echo "======================================================"
echo "oh-my-zsh and zsh config install done...."
echo "======================================================"
