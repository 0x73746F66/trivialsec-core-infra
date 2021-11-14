locals {
    aws_default_region    = "ap-southeast-2"
    aws_master_account_id = 984310022655
    linode_default_image    = "linode/alpine3.14"
    hosted_zone           = "Z04169281YCJD2GS4F5ER"
    domain                = "trivialsec"
    apex_domain           = "trivialsec.com"
    fw_ipv4_allowed       = [
        "180.150.30.218/32" # Chris
    ]
    fw_ipv6_allowed       = []
}
