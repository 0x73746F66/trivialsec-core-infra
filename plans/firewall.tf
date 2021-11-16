resource "linode_firewall" "saas_firewall" {
  label = "trivialsec"
  tags  = ["SaaS"]

  inbound {
    label    = "allow-HTTP"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "80"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound {
    label    = "allow-HTTPS"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "443"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound {
    label    = "allow-SSH"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "22"
    ipv4     = local.fw_ipv4_allowed
    ipv6     = local.fw_ipv6_allowed
  }

  inbound {
    label    = "allow-PROXY"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "3128"
    ipv4     = local.fw_ipv4_allowed
    ipv6     = local.fw_ipv6_allowed
  }

  inbound {
    label    = "allow-MYSQL"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "3306"
    ipv4     = concat(data.terraform_remote_state.public_api.outputs.public_api_ipv4, data.terraform_remote_state.mysql.outputs.mysql_main_ipv4, data.terraform_remote_state.mysql.outputs.mysql_replica_ipv4, local.fw_ipv4_allowed)
    ipv6     = concat([data.terraform_remote_state.public_api.outputs.public_api_ipv6, data.terraform_remote_state.mysql.outputs.mysql_main_ipv6, data.terraform_remote_state.mysql.outputs.mysql_replica_ipv6], local.fw_ipv6_allowed)
  }

  inbound {
    label    = "allow-ES"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "9300"
    ipv4     = local.fw_ipv4_allowed
    ipv6     = local.fw_ipv6_allowed
  }

  inbound {
    label    = "allow-WAF"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "8888"
    ipv4     = concat(data.terraform_remote_state.waf.outputs.ingress_ipv4, local.fw_ipv4_allowed)
    ipv6     = concat([data.terraform_remote_state.waf.outputs.ingress_ipv6], local.fw_ipv6_allowed)
  }

  inbound {
    label    = "allow-REDIS"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "6379"
    ipv4     = concat(data.terraform_remote_state.public_api.outputs.public_api_ipv4, local.fw_ipv4_allowed)
    ipv6     = concat([data.terraform_remote_state.public_api.outputs.public_api_ipv6], local.fw_ipv6_allowed)
  }

  inbound_policy = "DROP"
  outbound_policy = "ACCEPT"

  linodes = [
      data.terraform_remote_state.public_api.outputs.public_api_id,
      data.terraform_remote_state.waf.outputs.ingress_id,
      data.terraform_remote_state.mysql.outputs.mysql_main_id,
      data.terraform_remote_state.mysql.outputs.mysql_replica_id,
      data.terraform_remote_state.elasticsearch.outputs.es_id,
      data.terraform_remote_state.redis.outputs.redis_id,
  ]
}
