#!/usr/bin/env bash

HELM_VERSION=v2.16.7
HELM3_VERSION=v3.2.3

echo -e "\nUpdate helm $HELM_VERSION and helm $HELM3_VERSION..."
echo ""

echo "Removed old helm versions"
rm -rf /usr/local/bin/helm*


echo install helm v2
TMP_PATH="$HOME/.dotfiles/.tmp"
[ ! -d "$TMP_PATH" ] && mkdir -p "$TMP_PATH"
[ ! -d "$TMP_PATH/helm2" ] && mkdir -p "$TMP_PATH/helm2"
[ ! -d "$TMP_PATH/helm3" ] && mkdir -p "$TMP_PATH/helm3"

wget https://get.helm.sh/helm-${HELM_VERSION}-darwin-amd64.tar.gz -O $TMP_PATH/helm2.tar.gz; tar -xf $TMP_PATH/helm2.tar.gz -C $TMP_PATH/helm2; rm $TMP_PATH/helm2.tar.gz
wget https://get.helm.sh/helm-${HELM3_VERSION}-darwin-amd64.tar.gz -O $TMP_PATH/helm3.tar.gz; tar -xf $TMP_PATH/helm3.tar.gz -C $TMP_PATH/helm3; rm $TMP_PATH/helm3.tar.gz

echo -e "\\ninstall helm $HELM_VERSION"
cp -p $TMP_PATH/helm2/darwin-amd64/helm /usr/local/bin/helm
cp -p $TMP_PATH/helm2/darwin-amd64/helm /usr/local/bin/helm2

echo -e "\\ninstall helm $HELM3_VERSION"
cp -p $TMP_PATH/helm3/darwin-amd64/helm /usr/local/bin/helm3

[ -d "$TMP_PATH" ] && rm -rf $TMP_PATH

echo ""
echo -e "\nUpdate helm $HELM_VERSION and helm $HELM3_VERSION done!"
echo ""
