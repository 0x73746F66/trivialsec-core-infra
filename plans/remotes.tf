data "terraform_remote_state" "waf" {
  backend = "s3"
  config = {
    bucket      = "stateful-trivialsec"
    key         = "terraform/ingress-controller"
    region      = "ap-southeast-2"
  }
}
data "terraform_remote_state" "mysql" {
  backend = "s3"
  config = {
    bucket      = "stateful-trivialsec"
    key         = "terraform/mysql"
    region      = "ap-southeast-2"
  }
}
data "terraform_remote_state" "elasticsearch" {
  backend = "s3"
  config = {
    bucket      = "stateful-trivialsec"
    key         = "terraform/elasticsearch"
    region      = "ap-southeast-2"
  }
}
data "terraform_remote_state" "public_api" {
  backend = "s3"
  config = {
    bucket      = "stateful-trivialsec"
    key         = "terraform/public-api"
    region      = "ap-southeast-2"
  }
}
