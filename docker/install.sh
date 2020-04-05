#!/usr/bin/env bash

echo -e "\\n\\nInstall Docker, docker-compose, minikube, kubernetes-cli rancher-cli helm v2 and helm v3..."
echo ""

# Install command-line tools using Homebrew.
which -s brew
if [[ $? != 0 ]] ; then
    # Install Homebrew
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Make sure we’re using the latest Homebrew.
brew update
# Upgrade any already-installed formulae.
brew upgrade

brew tap "homebrew/cask"
brew tap "homebrew/cask-drivers"

brew cask install docker
brew install boot2docker
brew install docker-compose
brew install minikube
brew install kubernetes-cli
brew install rancher-cli

# Remove outdated versions from the cellar.
brew cleanup

echo install helm v2
[ ! -d "./.tmp" ] && mkdir -p ./.tmp

curl -LO https://get.helm.sh/helm-v2.16.5-darwin-amd64.tar.gz
mv ./helm-v2.16.5-darwin-amd64.tar.gz ./.tmp
tar -zxvf ./.tmp/helm-v2.16.5-darwin-amd64.tar.gz
chmod +x ./.tmp/darwin-amd64/helm
mv ./.tmp/darwin-amd64/helm /usr/local/bin/helm

echo install helm v3
curl -LO https://get.helm.sh/helm-v3.1.2-darwin-amd64.tar.gz
mv ./helm-v2.16.5-darwin-amd64.tar.gz ./.tmp
tar -zxvf ./.tmp/helm-v3.1.2-darwin-amd64.tar.gz
chmod +x ./.tmp/darwin-amd64/helm
mv ./.tmp/darwin-amd64/helm /usr/local/bin/helm

[ -d "./.tmp" ] && rm -rf ./.tmp

echo ""
echo -e "\\n\\nInstall Docker, docker-compose, minikube, kubernetes-cli rancher-cli helm v2 and helm v3 done!"
echo ""
