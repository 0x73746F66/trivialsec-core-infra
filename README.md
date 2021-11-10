# <img src=".repo/assets/icon-512x512.png"  width="52" height="52"> TrivialSec

[![pipeline status](https://gitlab.com/trivialsec/core/badges/main/pipeline.svg)](https://gitlab.com/trivialsec/core/commits/main)

# This repo

# AWS Setup

- Create account
- Create saml-provider via IAM Identity Providers: saml-provider/JumpCloud with SSO service location: https://sso.jumpcloud.com/saml2/aws1
- Create IAM Role FullAdmin with trust relationship to only the saml-provider/JumpCloud and managed policies: Billing, AdministratorAccess, AWSOrganizationsFullAccess, and AWSArtifactAccountSync
- Create IAM Role ServiceAccountRole with trust relationship to this account and the saml-provider/JumpCloud
- Create IAM Policy ServiceAccountPolicy which currently needs CloudFront, IAM, Route53, S3, STS, Systems Manager
- In us-east-1 region, create an ACM cert for `trivialsec.com` and `*.trivialsec.com` using email validation

# Gitlab CI access to AWSS

- Create IAM User gitlab-ci
- Attach GitlabPolicy

# AWS Service Accounts

- Create IAM User chris-service-account (use your name)
- Attach ServiceAccountPolicy

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
git clone git@gitlab.com:trivialsec/core.git
git clone git@gitlab.com:trivialsec/appserver.git
git clone git@gitlab.com:trivialsec/push-service.git
git clone git@gitlab.com:trivialsec/aws-iac.git
git clone git@gitlab.com:trivialsec/containers-common.git
git clone git@gitlab.com:trivialsec/forward-proxy.git
git clone git@gitlab.com:trivialsec/ingress-controller.git
git clone git@gitlab.com:trivialsec/mysql.git
git clone git@gitlab.com:trivialsec/public-api.git
git clone git@gitlab.com:trivialsec/python-common.git
git clone git@gitlab.com:trivialsec/python-webhooks.git
git clone git@gitlab.com:trivialsec/screenshots.git
git clone git@gitlab.com:trivialsec/website.git
git clone git@gitlab.com:trivialsec/workers.git
```

## Create VS Code workspace

Create `.trivialsec.code-workspace` file with contents of the file in this repo, place it in `$HOME/trivialsec`

## Create your own AWS Service account

old method: using the CloudFormation template in the `aws-iac` repo and then configure your awscli.

## Get the platform running locally

Run `make setup`, `make build`, and `make up` in the `containers-common` which will build the python and nodejs base images for docker and bring up MySQL and Redis locally.

Run `make package-local` in the `python-common` repo to build the libs needed for the API, App, and Workers projects.
In `workers` run `make package`.

In `push-service`, `app-server`, `public-api`, and `workers` projects run `make build` and `make up`.

For stripe development webhooks, run `make stripe-dev` in `app-server` project after the `app-server` itself is running.

## Note on linode PAT

The UI method for creating PAT do not allow you to add firewall resource permissions.

To create Linode Personal API Token (PAT) with:

```sh
curl -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TF_VAR_linode_token" \
    -X POST -d '{
        "scopes": "firewall:read_write maintenance:read_only account:read_only domains:read_only events:read_only images:read_write ips:read_write linodes:read_write longview:read_only stackscripts:read_write volumes:read_write",
        "expiry": "2080-01-01T23:59:59",
        "label": "stof-pat"
    }' \
    https://api.linode.com/v4/profile/tokens
```

https://www.linode.com/docs/api/#oauth-reference

```
account:read_only          Allows access to GET information about your Account.
account:read_write         Allows access to all endpoints related to your Account.
domains:read_only          Allows access to GET Domains on your Account.
domains:read_write         Allows access to all Domain endpoints.
events:read_only           Allows access to GET your Events.
events:read_write          Allows access to all endpoints related to your Events.
firewall:read_only         Allows access to GET information about your Firewalls.
firewall:read_write        Allows access to all Firewall endpoints.
images:read_only           Allows access to GET your Images.
images:read_write          Allows access to all endpoints related to your Images.
ips:read_only              Allows access to GET your ips.
ips:read_write             Allows access to all endpoints related to your ips.
linodes:read_only          Allows access to GET Linodes on your Account.
linodes:read_write         Allow access to all endpoints related to your Linodes.
lke:read_only              Allows access to GET LKE Clusters on your Account.
lke:read_write             Allows access to all endpoints related to LKE Clusters on your Account.
longview:read_only         Allows access to GET your Longview Clients.
longview:read_write        Allows access to all endpoints related to your Longview Clients.
maintenance:read_only      Allows access to GET information about Maintenance on your account.
nodebalancers:read_only    Allows access to GET NodeBalancers on your Account.
nodebalancers:read_write   Allows access to all NodeBalancer endpoints.
object_storage:read_only   Allows access to GET information related to your Object Storage.
object_storage:read_write  Allows access to all Object Storage endpoints.
stackscripts:read_only     Allows access to GET your StackScripts.
stackscripts:read_write    Allows access to all endpoints related to your StackScripts.
volumes:read_only          Allows access to GET your Volumes.
volumes:read_write         Allows access to all endpoints related to your Volumes.
```