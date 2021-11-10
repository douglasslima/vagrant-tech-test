#!/usr/bin/env bash

# Installing and configuring Terraform:
# -------------------------------------------------------------------------
echo "Installing unzip"
REQUIRED_PKG="unzip"
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
echo Checking for $REQUIRED_PKG: $PKG_OK
if [ "" = "$PKG_OK" ]; then
  echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
  sudo apt-get --yes install $REQUIRED_PKG
fi

CACHE="/home/vagrant/documents/bin"
TERRAFORM_DOCS_VERSION="v0.14.1"
TERRAFORM_DOCS_FILE=$CACHE/terraform-docs-${TERRAFORM_DOCS_VERSION}-linux-amd64.tar.gz

export PATH="$HOME/.tfenv/bin:$PATH"
echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bashrc

echo "Installing and configuring Terraform via tfenv"
git clone https://github.com/tfutils/tfenv.git $HOME/.tfenv
tfenv install 0.14.6 > /dev/null

echo "Set Terraform 0.14.6 as the default"
tfenv use 0.14.6
chown -R $USER:$USER $HOME/.tfenv

echo "Install terraform docs ${TERRAFORM_DOCS_VERSION}"
if [ ! -f $TERRAFORM_DOCS_FILE ]; then
  curl -s -L -o $TERRAFORM_DOCS_FILE https://github.com/terraform-docs/terraform-docs/releases/download/${TERRAFORM_DOCS_VERSION}/terraform-docs-${TERRAFORM_DOCS_VERSION}-linux-amd64.tar.gz
fi

tar -vzxf $TERRAFORM_DOCS_FILE -C /tmp
sudo cp /tmp/terraform-docs /usr/local/bin/terraform-docs
sudo chmod a+x /usr/local/bin/terraform-docs

echo "Install tflint"
curl https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | sudo bash

echo "Create Terraform cache directory"
mkdir -p /tmp/tf_cache
sudo chown $USER:$USER /tmp/tf_cache