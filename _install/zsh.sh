#!/usr/bin/env bash

echo -e "Install zsh...."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

stow ~/.dotfiles/zsh

# Install tool for cleanup the mac
curl -o cleanup https://raw.githubusercontent.com/fwartner/mac-cleanup/master/cleanup.sh
chmod +x cleanup
mv cleanup /usr/local/bin/cleanup

echo -e "Install zsh done!"
