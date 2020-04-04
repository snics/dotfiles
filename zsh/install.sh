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

brew tap homebrew/command-not-found

brew install zsh
brew install zsh-completions
brew install zsh-autosuggestions
brew install fasd

sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

cp -f -r $HOME/.dotfiles/zsh/plugins/* $HOME/.oh-my-zsh/custom/plugins

wget https://raw.githubusercontent.com/caiogondim/bullet-train-oh-my-zsh-theme/master/bullet-train.zsh-theme -O $HOME/.oh-my-zsh/custom/themes/bullet-train.zsh-theme
git clone https://github.com/akarzim/zsh-docker-aliases.git $HOME/.oh-my-zsh/custom/plugins/docker-aliases
git clone https://github.com/zsh-users/zsh-completions $HOME/.oh-my-zsh/custom/plugins/zsh-completions
git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions

cp -f $HOME/.dotfiles/zsh/.zshrc ~/.zshrc

# Permissions error
source ~/.zshrc
compaudit | xargs chmod g-w

curl -o cleanup https://raw.githubusercontent.com/fwartner/mac-cleanup/master/cleanup.sh
chmod +x cleanup
mv cleanup /usr/local/bin/cleanup

echo ""
echo "Setup oh-my-zsh and zsh settings done...."
echo ""
