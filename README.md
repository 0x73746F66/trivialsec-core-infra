# <img src=".repo/assets/icon-512x512.png"  width="52" height="52"> TrivialSec

[![pipeline status](https://gitlab.com/trivialsec/core/badges/main/pipeline.svg)](https://gitlab.com/trivialsec/core/commits/main)

# This repo

TBC

# Workspace Setup

## Get setup with JumpCloud and gitlab.com

## Install packages

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt update && sudo apt install python3-pip python3-venv docker-ce docker-ce-cli containerd.io docker-compose
sudo usermod -aG docker $(id -un)
sudo systemctl enable docker
pip install -q -U pip pipx setuptools wheel
pipx install awscli
pipx install pylint
pipx install semgrep
pipx install linode-cli
```

## Install bitwarden cli

```bash
unzip -d ~/.local/bin =( wget -qO- 'https://vault.bitwarden.com/download/?app=cli&platform=linux' )
chmod a+x ~/.local/bin/bw
```

## install Terraform

```bash
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com focal main"
sudo apt-get update && sudo apt-get install -y terraform
terraform -install-autocomplete
```

## Run some clone commands

```bash
mkdir -p $HOME/trivialsec
cd $HOME/trivialsec
git clone git@gitlab.com:trivialsec/appserver.git
git clone git@gitlab.com:trivialsec/push-service.git
git clone git@gitlab.com:trivialsec/aws-iac.git
git clone git@gitlab.com:trivialsec/containers-common.git
git clone git@gitlab.com:trivialsec/forward-proxy.git
git clone git@gitlab.com:trivialsec/public-api.git
git clone git@gitlab.com:trivialsec/python-common.git
git clone git@gitlab.com:trivialsec/python-webhooks.git
git clone git@gitlab.com:trivialsec/screenshots.git
git clone git@gitlab.com:trivialsec/website.git
git clone git@gitlab.com:trivialsec/workers.git
```

## Create VS Code workspace

Create `.trivialsec.code-workspace` file with contents;

```json

```

## Create your own AWS Service account
using the CloudFormation template in the `aws-iac` repo and then configure your awscli.

## Get the platform running locally

Run `make setup`, `make build`, and `make up` in the `containers-common` which will build the python and nodejs base images for docker and bring up MySQL and Redis locally.

Run `make package-local` in the `python-common` repo to build the libs needed for the API, App, and Workers projects.
In `workers` run `make package`.

In `push-service`, `app-server`, `public-api`, and `workers` projects run `make build` and `make up`.

For stripe development webhooks, run `make stripe-dev` in `app-server` project after the `app-server` itself is running.
