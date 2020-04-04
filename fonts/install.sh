#!/usr/bin/env bash

echo "======================================================"
echo "Welcome to fonts Installation."
echo "======================================================"


git clone https://github.com/powerline/fonts.git --depth=1 ./powerline-fonts
bash ./powerline-fonts/install.sh
rm -rf ./powerline-fonts

cp -f $HOME/.dotfiles/fonts/* $HOME/Library/Fonts

echo "======================================================"
echo "Donts install done...."
echo "======================================================"
