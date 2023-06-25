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

# Docker
brew install docker
brew install docker-compose
brew install lazydocker

# Kubernetes
brew install minikube
brew install kubernetes-cli
brew install kind

# Rancher tools
brew install rancher-cli
brew install rke

# Helm
brew install helm

# podman
brew install podman
brew install podman-desktop

# Lima
brew install lima

# trivy
brew install trivy

# OpenShift
brew install openshift-cli

# Kuberntes GUIs
brew install --cask lens
brew install --cask kubenav

# Remove outdated versions from the cellar.
brew cleanup

HELM_VERSION=v2.17.0

echo "install helm $HELM_VERSION"
TMP_PATH="$HOME/.dotfiles/.tmp"
[ ! -d "$TMP_PATH" ] && mkdir -p "$TMP_PATH"
[ ! -d "$TMP_PATH/helm2" ] && mkdir -p "$TMP_PATH/helm2"

wget https://get.helm.sh/helm-${HELM_VERSION}-darwin-amd64.tar.gz -O $TMP_PATH/helm2.tar.gz; tar -xf $TMP_PATH/helm2.tar.gz -C $TMP_PATH/helm2; rm $TMP_PATH/helm2.tar.gz

echo -e "\\ninstall helm $HELM_VERSION"
cp -p $TMP_PATH/helm2/darwin-amd64/helm /usr/local/bin/helm2

[ -d "$TMP_PATH" ] && rm -rf $TMP_PATH

cp -p $HOME/.dotfiles/docker/helm-update.sh /usr/local/bin/helm-update
chmod 775 /usr/local/bin/helm-update

echo ""
echo -e "\\n\\nInstall Docker, docker-compose, minikube, kubernetes-cli rancher-cli helm v2, helm v3 podman done!"
echo ""
