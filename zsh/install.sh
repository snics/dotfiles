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
brew install fasd

sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

cp -f -r $HOME/.dotfiles/zsh/plugins/* $HOME/.oh-my-zsh/custom/plugins

wget https://raw.githubusercontent.com/caiogondim/bullet-train-oh-my-zsh-theme/master/bullet-train.zsh-theme -O $HOME/.oh-my-zsh/custom/themes/bullet-train.zsh-theme
git clone https://github.com/akarzim/zsh-docker-aliases.git $HOME/.oh-my-zsh/custom/plugins/docker-aliases
git clone https://github.com/zsh-users/zsh-completions $HOME/.oh-my-zsh/custom/plugins/zsh-completions
git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/bernardop/iterm-tab-color-oh-my-zsh.git $HOME/.oh-my-zsh/custom/plugins/iterm-tab-color
git clone git@github.com:igoradamenko/npm.plugin.zsh.git $HOME/.oh-my-zsh/custom/plugins/npm
git clone https://github.com/torifat/npms.git $HOME/.oh-my-zsh/custom/plugins/npms
git clone https://github.com/dijitalmunky/nvm-auto.git $HOME/.oh-my-zsh/custom/plugins/nvm-auto
git clone https://github.com/ytet5uy4/fzf-widgets.git $HOME/.oh-my-zsh/custom/plugins/fzf-widgets
git clone https://github.com/lukechilds/zsh-better-npm-completion $HOME/.oh-my-zsh/custom/plugins/zsh-better-npm-completion

# Custom configs
cp -f $HOME/.dotfiles/zsh/custom/.tc-config $HOME/.oh-my-zsh/custom/plugins/iterm-tab-color/.tc-config

cp -f $HOME/.dotfiles/zsh/.zshrc ~/.zshrc

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
