#!/usr/bin/env bash
set -e

# Installing and configuring Base packages:
# -------------------------------------------------------------------------

sudo apt-get -y update
sudo apt-get -y install \
  apt-transport-https \
  build-essential \
  ca-certificates \