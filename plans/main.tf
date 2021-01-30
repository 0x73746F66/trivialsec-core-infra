provider "aws" {
    region  = local.default_region
    profile = local.default_profile
    allowed_account_ids = [local.master_account_id]
}

terraform {
    backend "s3" {
        bucket = "trivialsec-assets"
        key    = "terraform/statefiles/iac"
        region = "ap-southeast-2"
    }
}
