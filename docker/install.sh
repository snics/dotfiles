#!/usr/bin/env bash

echo "======================================================"
echo "Welcome to Homebrew formulae dotfiles Installation."
echo "======================================================"

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
curl -LO https://get.helm.sh/helm-v2.16.5-darwin-amd64.tar.gz
tar -zxvf ./helm-v2.16.5-darwin-amd64.tar.gz
mv ./darwin-amd64/helm /usr/local/bin/helm
rm -rf darwin-amd64

echo install helm v3
curl -LO https://get.helm.sh/helm-v3.1.2-darwin-amd64.tar.gz
tar -zxvf ./helm-v3.1.2-darwin-amd64.tar.gz
mv darwin-amd64/helm /usr/local/bin/helm3
rm -rf darwin-amd64

echo "======================================================"
echo "Homebrew formulae install done...."
echo "======================================================"
