#!/bin/bash
cat > .env <<CONFIG
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/_/_/_
LINODE_TOKEN=
RUNNER_TAGS=linode
RUNNER_TOKEN=tEsVJexEYzLJjL5rbg-f
RUNNER_NAME=trivialsec-shared
AWS_ACCESS_KEY_ID=AKIA
AWS_SECRET_ACCESS_KEY=

CONFIG

dnf -y install dnf-plugins-core
dnf config-manager \
    --add-repo \
    https://download.docker.com/linux/fedora/docker-ce.repo

dnf -y install docker-ce docker-ce-cli containerd.io python3-pip
python3 -m pip install -U pip
python3 -m pip install pipx
pipx install docker-compose
pipx install awscli
pipx install certbot
pipx inject certbot certbot-route53

systemctl enable docker.service
systemctl enable containerd.service
systemctl start docker
docker volume create linode-slack-db
docker volume create gitlab-cache
docker network create containers

docker login -u chrislangton -p E_hvCmcTi6soZDTA5USY registry.gitlab.com
docker pull registry.gitlab.com/trivialsec/containers-common/gitlab-runner

mkdir -p /root/linode-slackbot /root/nginx/config/ /root/letsencrypt/conf /root/letsencrypt/www
export PATH="$PATH:/root/.local/bin"
cat > .profile <<CONFIG
export PATH="$PATH:/root/.local/bin"

CONFIG
docker-compose pull
docker-compose up -d

# scp -r ./core/.linode.bak/statping linode:/root/
# Host linode
#   HostName 194.195.121.4
#   User root
#   IdentityFile /home/chris/.ssh/id_rsa
#   Compression yes
#   ConnectionAttempts 3
#   ConnectTimeout 5
#   IdentitiesOnly yes
