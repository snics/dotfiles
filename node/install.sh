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
npm i -g npx
npm i -g npkill
npm i -g npm-upgrade
npm i -g npm-check
npm i -g np
npm i -g npm-name-cli
npm i -g node-green-cli

echo ""
echo "Install node scripts utils!"
echo ""
curl -o- https://gist.githubusercontent.com/mabhub/5b9a32da340d89770eccbcfc3b702569/raw/9ebe6398427fa6e4e31d8a8f5d9e758ac679f5ca/nvm-list > /usr/local/bin/nvm-list && chmod -R a+rwx /usr/local/bin/nvm-list

echo ""
echo "Install node Node.js and NVM done!"
echo ""
