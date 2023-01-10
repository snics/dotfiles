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

brew install --cask docker
brew install boot2docker
brew install docker-compose
brew install minikube
brew install kubernetes-cli
brew install rancher-cli

# Remove outdated versions from the cellar.
brew cleanup

HELM_VERSION=v2.17.0
HELM3_VERSION=v3.4.2

echo "install helm $HELM_VERSION"
TMP_PATH="$HOME/.dotfiles/.tmp"
[ ! -d "$TMP_PATH" ] && mkdir -p "$TMP_PATH"
[ ! -d "$TMP_PATH/helm2" ] && mkdir -p "$TMP_PATH/helm2"
[ ! -d "$TMP_PATH/helm3" ] && mkdir -p "$TMP_PATH/helm3"

wget https://get.helm.sh/helm-${HELM_VERSION}-darwin-amd64.tar.gz -O $TMP_PATH/helm2.tar.gz; tar -xf $TMP_PATH/helm2.tar.gz -C $TMP_PATH/helm2; rm $TMP_PATH/helm2.tar.gz
wget https://get.helm.sh/helm-${HELM_VERSION}-darwin-amd64.tar.gz -O $TMP_PATH/helm3.tar.gz; tar -xf $TMP_PATH/helm3.tar.gz -C $TMP_PATH/helm3; rm $TMP_PATH/helm3.tar.gz

echo -e "\\ninstall helm $HELM_VERSION"
cp -p $TMP_PATH/helm2/darwin-amd64/helm /usr/local/bin/helm
cp -p $TMP_PATH/helm2/darwin-amd64/helm /usr/local/bin/helm2

echo -e "\\ninstall helm $HELM3_VERSION"
cp -p $TMP_PATH/helm3/darwin-amd64/helm /usr/local/bin/helm3

[ -d "$TMP_PATH" ] && rm -rf $TMP_PATH

cp -p $HOME/.dotfiles/docker/helm-update.sh /usr/local/bin/helm-update
chmod 775 /usr/local/bin/helm-update

echo ""
echo -e "\\n\\nInstall Docker, docker-compose, minikube, kubernetes-cli rancher-cli helm v2 and helm v3 done!"
echo ""
