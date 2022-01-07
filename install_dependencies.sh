#!/bin/bash

# terraform-docs
sudo curl -Lo ./terraform-docs.tar.gz https://github.com/terraform-docs/terraform-docs/releases/download/v0.16.0/terraform-docs-v0.16.0-$(uname)-amd64.tar.gz
sudo tar -xzf ./terraform-docs.tar.gz
sudo chmod +x ./terraform-docs
sudo mv ./terraform-docs /usr/local/terraform-docs
sudo rm -Rf ./terraform-docs.tar.gz

# terrascan
sudo curl -Lo ./terrascan.tar.gz "$(curl -s https://api.github.com/repos/accurics/terrascan/releases/latest | grep -o -E "https://.+?_Linux_x86_64.tar.gz")"
sudo tar -xzf ./terrascan.tar.gz
sudo mv ./terrascan /usr/local/bin
sudo rm -Rf terrascan.tar.gz

# tfsec
sudo curl -Lo ./tfsec "$(curl -s https://api.github.com/repos/aquasecurity/tfsec/releases/latest | grep -o -E "https://.+?-linux-amd64" | sort -u)"
sudo chmod +x ./tfsec
sudo mv ./tfsec /usr/local/bin

#tflint
#https://github.com/terraform-linters/tflint/blob/master/docs/user-guide/config.md
#https://github.com/terraform-linters/tflint-ruleset-aws

sudo curl -Lo ./tflint.zip "$(curl -s https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E "https://.+?_linux_amd64.zip" | sort -u)"
sudo unzip ./tflint.zip
sudo mv ./tflint /usr/local/bin
sudo rm -Rf ./tflint.zip
sudo rm -Rf ~/.tflint.d
cat > ~/.tflint.hcl << EOF
config {
  plugin_dir = "~/.tflint.d/plugins"
  varfile = ["terraform.tfvars"]
}

plugin "aws" {
  enabled = true
  version = "0.11.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}
EOF
tflint --init
