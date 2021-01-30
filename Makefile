SHELL := /bin/bash
-include .env
export $(shell sed 's/=.*//' .env)
APP_NAME := website

.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

CMD_AWS := aws
ifdef AWS_PROFILE
CMD_AWS += --profile $(AWS_PROFILE)
endif
ifdef AWS_REGION
CMD_AWS += --region $(AWS_REGION)
endif

upload:
	$(CMD_AWS) s3 cp --only-show-errors --recursive --include="*.yaml" ./templates s3://trivialsec-assets/cloudformation/

setup-deb:
	pip install -q -U pip awscli
	curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
	sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com focal main"
	sudo apt-get update && sudo apt-get install -y terraform
	terraform -install-autocomplete
	terraform init plans

update:
	git pull

plan:
	mkdir -p build
	terraform validate plans
	terraform plan -no-color -out=build/.tfplan plans

deploy:
	terraform apply -auto-approve -refresh=true build/.tfplan
