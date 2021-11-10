#!/usr/bin/env bash

# Installing and configuring Helm:
# -------------------------------------------------------------------------

CACHE="/tmp"
HELM_VERSION="v3.1.1"
HELM_FILE=$CACHE/helm_${HELM_VERSION}_linux_amd64

echo "Installing and configuring Helm ${HELM_VERSION}"
if [ ! -f $HELM_FILE ]; then
  curl -s -L -o $HELM_FILE https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz
fi

sudo tar -vzxf $HELM_FILE
sudo cp linux-amd64/helm /usr/local/bin/
sudo chmod a+x /usr/local/bin/helm
sudo rm -rf linux-amd64