#!/usr/bin/env bash

echo -e "\\n\\nSetup oh-my-zsh and zsh settings."
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

brew install zsh
brew install fzf
brew install peco
brew install exa
brew install bat
brew install zplug
brew install google-cloud-sdk

sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

ln -s -f $HOME/.dotfiles/zsh/plugins $HOME/.oh-my-zsh/custom/plugins

# Custom configs
ln -s -f $HOME/.dotfiles/zsh/custom/.tc-config $HOME/.oh-my-zsh/custom/plugins/iterm-tab-color/.tc-config

ln -s -f $HOME/.dotfiles/zsh/.zshrc ~/.zshrc
ln -s -f $HOME/.dotfiles/zsh/starship.toml ~/.config/starship.toml

# Permissions error
source ~/.zshrc
compaudit | xargs chmod g-w

# Install tool for cleanup the mac
curl -o cleanup https://raw.githubusercontent.com/fwartner/mac-cleanup/master/cleanup.sh
chmod +x cleanup
mv cleanup /usr/local/bin/cleanup

echo ""
echo "Setup oh-my-zsh and zsh settings done...."
echo ""
