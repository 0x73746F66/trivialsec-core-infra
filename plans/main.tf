provider "linode" {
    token = var.linode_token
}

provider "aws" {
    region              = local.aws_default_region
    secret_key          = var.aws_secret_access_key
    access_key          = var.aws_access_key_id
    allowed_account_ids = [local.aws_master_account_id]
}

terraform {
    required_version = ">= 1.0.10"

    required_providers {
        linode = {
            source = "linode/linode"
            version = ">= 1.23.0"
        }
        local = {
            source = "hashicorp/local"
            version = ">= 2.1.0"
        }
        aws = {
            source = "hashicorp/aws"
            version = ">= 3.64.2"
        }
    }
    backend "s3" {
        bucket      = "stateful-trivialsec"
        key         = "terraform/core"
        region      = "ap-southeast-2"
    }
}
