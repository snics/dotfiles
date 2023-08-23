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

## Docker

# Docker allows you to run applications in containers. It is an open platform for containerization.
brew install --cask docker

# docker-compose is a tool for defining and running multi-container Docker applications.
brew install docker-compose

# lazydocker is a simple terminal UI for Docker with keyboard shortcuts.
brew install lazydocker

# dive is a tool to explore a Docker image, layer contents, and discover ways to reduce image size.
brew install dive

# Skopeo is a command-line utility that performs various operations on container images and image repositories. In English: Skopeo is a command line utility to work with container images and repositories.
brew install skopeo

# Container-diff is a tool to analyze differences between container images. In English: Container-diff is a tool for analyzing and comparing container images.
brew install container-diff

# Lynis is a security auditing tool for UNIX systems, like Linux, macOS, and others. In English: Lynis is a security and system auditing tool for Unix-based systems.
brew install lynis

# Sysdig is an open-source system monitoring and tracing tool.
brew install sysdig

# Ctop provides a concise real-time view of container metrics.
brew install ctop

# Hadolint is a linter for Dockerfiles to ensure best practices are followed.
brew install hadolint

# Clair is an open-source project for the static analysis of vulnerabilities in container images.
brew install clair

# Reg is a lightweight tool to interact with Docker registry.
brew install reg

# Docker-slim optimizes and reduces the size of Docker images without manual tuning.
brew install docker-slim

## Kubernetes

# Minikube is a tool that allows running Kubernetes locally. In German: Minikube ist ein Werkzeug, das es ermöglicht, Kubernetes lokal auszuführen.
brew install minikube

# kubernetes-cli (kubectl) is a command-line tool to interact with Kubernetes clusters.
brew install kubernetes-cli

# kind stands for Kubernetes IN Docker. It runs local Kubernetes clusters using Docker container "nodes".
brew install kind

# Helm is a package manager for Kubernetes.
brew install helm

# podman is a tool to manage containers and images, similar to Docker, but without a central daemon.
brew install podman

# podman-desktop provides a GUI for the podman tool.
brew install --cask podman-desktop

# Lima is a lightweight virtualization tool that allows you to run Linux VMs with ease.
brew install lima

# Trivy is a vulnerability scanner for containers and other artifacts.
brew install trivy

brew install kompose

# openshift-cli is a command-line tool for managing OpenShift, a Kubernetes distribution from Red Hat.
brew install openshift-cli

# Kompose is a tool to help users familiar with 'docker-compose' transition to Kubernetes.
brew install kompose

# Kubernetes GUIs
# Lens is a Kubernetes integrated development environment (IDE).
brew install --cask lens

# kubenav is a mobile, desktop, and web-based application to manage Kubernetes clusters.
brew install --cask kubenav

## Rancher tools
# rancher-cli is a command-line tool for interacting with Rancher, a container management platform.
brew install rancher-cli

# rke (Rancher Kubernetes Engine) is a program to run Kubernetes clusters within containers.
brew install rke

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
