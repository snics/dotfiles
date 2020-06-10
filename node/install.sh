#!/usr/bin/env bash

echo -e "\\n\\nInstall node Node.js and NVM...."
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

brew install node
brew install deno

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash

echo ""
echo "Install node CLI tools!"
echo ""
npm i -g npkill
npm i -g npm-upgrade
npm i -g npm-check
npm i -g np
npm i -g npm-name-cli


echo ""
echo "Install node Node.js and NVM done!"
echo ""
