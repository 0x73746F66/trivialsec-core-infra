# <img src=".repo/assets/icon-512x512.png"  width="52" height="52"> TrivialSec

[![pipeline status](https://gitlab.com/trivialsec/core/badges/main/pipeline.svg)](https://gitlab.com/trivialsec/core/commits/main)

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

- terraform
- docker
- python3 or newer
- `python3 -m pip install --user pipx`
- a few self-contained pip packages:

```bash
pip install -U setuptools wheel 
pipx install awscli
pipx install pylint
pipx install semgrep
pipx install linode-cli
```

## Install bitwarden cli (or just the browser plugin is fine)

```bash
unzip -d ~/.local/bin =( wget -qO- 'https://vault.bitwarden.com/download/?app=cli&platform=linux' )
chmod a+x ~/.local/bin/bw
```

## Create VS Code workspace

Create a workspace directory, typically `mkdir -p $HOME/trivialsec`

### Run some clone commands

I like [ghorg](github.com/gabrie30/ghorg)

```bash
cd $HOME/trivialsec
go install github.com/gabrie30/ghorg@latest
ghorg clone trivialsec --branch=main --skip-forks --scm=gitlab
```

Create `.trivialsec.code-workspace` file with contents of the file in this (`core`) repo, place it in `$HOME/trivialsec`

## Create your own AWS Service account

TODO

## Get the platform running locally

Make sure `APP_NAME` is set to something unique to you (defualts to your username and hostname but feel free to change that `APP_NAME`)

And run `make docker-login` after setting `GITLAB_PAT` and `GITLAB_USER` 

### core

```bash
source .in
./bin/secrets
./bin/update-app-configs
```

### elasticsearch

```bash
source .in
./bin/secrets
make setup
make up
```

### mysql

```bash
source .in
./bin/secrets
make setup
make up
```

### redis

```bash
source .in
./bin/secrets
make setup
make up
```

### public-api

```bash
source .in
make setup
make build
make up
make python-libs
```

### appserver

```bash
source .in
./bin/secrets
make setup
make build
make up
make python-libs
```

### website

```bash
source .in
make build
make up
```

Run the following in thier own terminal sessions:

```bash
npm run watch-sass
npm run watch-js
```

### Push Service

```bash
source .in
make build
make up
```

### ingress-controller

```bash
source .in
./bin/secrets
make setup
make gencerts
make build
make up
```

#### Apply changes made to nginx `conf.d` files

```bash
# test configs
docker-compose exec ingress-controller nginx -t
# apply changes
docker-compose exec ingress-controller nginx -s reload
```

### Batch Tasks

```bash
source .in
make python-libs
make setup
make build
make up
```

#### First time setup:

```bash
# "hostname": "batch.trivialsec"
docker-compose exec batch /opt/cronicle/bin/storage-cli.js edit global/servers/0
# "regexp": "^(batch.trivialsec)$"
docker-compose exec batch /opt/cronicle/bin/storage-cli.js edit global/server_groups/0
```

Once done these are persisted to the `cronicle-datadir` volume

#### Executing a specific job directly:

```bash
docker-compose exec --user=trivialsec:trivialsec batch python src/load_exploitdb.py -r -v
```

Keep things up-to-date locally using `.development/crontab` - but Cronicle actually runs the same locally as in prod if you configure it to do so

#### Checking logs:

```bash
# combined task execution errors and task result outputs log
docker-compose exec batch tail -f /var/log/trivialsec/tasks.log
# all tasks JSON results
docker-compose exec batch tail -f /var/log/trivialsec/task-runner.log
# all task errors
docker-compose exec batch tail -f /var/log/trivialsec/error.log
# or a sepcific job JSON results
docker-compose exec batch tail -f /var/log/trivialsec/load_exploitdb.py.log
```

#### Is Cronicle and the tasks running?

```bash
# quick easy check; are logs being created?
docker-compose exec batch watch -cn1 ls -la /var/log/trivialsec
# Maybe it's not 'time' for any jobs to execute, wait for something to happen
docker-compose exec batch watch -cn1 ps aux -N r -H
```

#### Cronicle data backup and restore:

```bash
docker-compose exec batch /opt/cronicle/bin/control.sh export > cronicle-export.bak
# restore; first copy the backup into the docker container
docker cp cronicle-export.bak batch:/tmp/backup.txt
docker exec batch node /opt/cronicle/bin/storage-cli.js import /tmp/backup.txt
# restart container
```

#### Cronicle Shell Script for Cronicle schedules:

```bash
#!/bin/bash
/srv/app/src/runlog python /srv/app/src/load_exploitdb.py -r --only-show-errors
/srv/app/src/runlog python /srv/app/src/load_xforce.py -r --only-show-errors
/srv/app/src/runlog python /srv/app/src/load_aws_alas.py -y $(date '+%Y') --only-show-errors
/srv/app/src/runlog python /srv/app/src/load_oval.py -y --suse $(date '+%Y') --not-before $(date '+%Y-%m-%dT00:00:00' -d "1 day ago") --only-show-errors
/srv/app/src/runlog python /srv/app/src/load_oval.py -y --debian $(date '+%Y') --not-before $(date '+%Y-%m-%dT00:00:00' -d "1 day ago") --only-show-errors
/srv/app/src/runlog python /srv/app/src/load_oval.py -y --redhat $(date '+%Y') --not-before $(date '+%Y-%m-%dT00:00:00' -d "1 day ago") --only-show-errors
/srv/app/src/runlog python /srv/app/src/load_oval.py -y --cis $(date '+%Y') --not-before $(date '+%Y-%m-%dT00:00:00' -d "1 day ago") --only-show-errors
/srv/app/src/runlog python /srv/app/src/load_nvd_cve.py --latest --only-show-errors --not-before $(date '+%Y-%m-%dT%H:00Z' -d "2 hours ago")
/srv/app/src/runlog python /srv/app/src/load_nvd_cve.py --modified --only-show-errors --not-before $(date '+%Y-%m-%dT%H:00Z' -d "2 hours ago")
```

Webhooks are fired by Cronicle, filtered using Zapier, sent to Slack.

### workers

```bash

```

### webhooks

> TODO: FastAPI or Golang?

For now, Stripe development webhooks, just run `make stripe-dev` in `appserver` project after the `appserver` itself is running (to process the webhooks stripe will send).

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