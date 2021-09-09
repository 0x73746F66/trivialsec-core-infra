resource "aws_ssm_parameter" "elasticsearch_password" {
  name        = "/${var.app_env}/Deploy/${var.app_name}/elasticsearch_password"
  type        = "SecureString"
  value       = var.elasticsearch_password
  tags = {
    cost-center = "saas"
  }
  overwrite   = true
}
resource "aws_ssm_parameter" "mysql_main_password" {
  name        = "/${var.app_env}/Deploy/${var.app_name}/mysql_main_password"
  type        = "SecureString"
  value       = var.mysql_main_password
  tags = {
    cost-center = "saas"
  }
  overwrite   = true
}
resource "aws_ssm_parameter" "mysql_replica_password" {
  name        = "/${var.app_env}/Deploy/${var.app_name}/mysql_replica_password"
  type        = "SecureString"
  value       = var.mysql_replica_password
  tags = {
    cost-center = "saas"
  }
  overwrite   = true
}
resource "aws_ssm_parameter" "session_secret_key" {
  name        = "/${var.app_env}/Deploy/${var.app_name}/session_secret_key"
  type        = "SecureString"
  value       = var.session_secret_key
  tags = {
    cost-center = "saas"
  }
  overwrite   = true
}
resource "aws_ssm_parameter" "recaptcha_secret_key" {
  name        = "/${var.app_env}/Deploy/${var.app_name}/recaptcha_secret_key"
  type        = "SecureString"
  value       = var.recaptcha_secret_key
  tags = {
    cost-center = "saas"
  }
  overwrite   = true
}
resource "aws_ssm_parameter" "sendgrid_api_key" {
  name        = "/${var.app_env}/Deploy/${var.app_name}/sendgrid_api_key"
  type        = "SecureString"
  value       = var.sendgrid_api_key
  tags = {
    cost-center = "saas"
  }
  overwrite   = true
}
resource "aws_ssm_parameter" "stripe_secret_key" {
  name        = "/${var.app_env}/Deploy/${var.app_name}/stripe_secret_key"
  type        = "SecureString"
  value       = var.stripe_secret_key
  tags = {
    cost-center = "saas"
  }
  overwrite   = true
}
resource "aws_ssm_parameter" "stripe_webhook_secret" {
  name        = "/${var.app_env}/Deploy/${var.app_name}/stripe_webhook_secret"
  type        = "SecureString"
  value       = var.stripe_webhook_secret
  tags = {
    cost-center = "saas"
  }
  overwrite   = true
}
resource "aws_ssm_parameter" "google_api_key" {
  name        = "/${var.app_env}/Deploy/${var.app_name}/google_api_key"
  type        = "SecureString"
  value       = var.google_api_key
  tags = {
    cost-center = "saas"
  }
  overwrite   = true
}
resource "aws_ssm_parameter" "phishtank_key" {
  name        = "/${var.app_env}/Deploy/${var.app_name}/phishtank_key"
  type        = "SecureString"
  value       = var.phishtank_key
  tags = {
    cost-center = "saas"
  }
  overwrite   = true
}
resource "aws_ssm_parameter" "honeyscore_key" {
  name        = "/${var.app_env}/Deploy/${var.app_name}/honeyscore_key"
  type        = "SecureString"
  value       = var.honeyscore_key
  tags = {
    cost-center = "saas"
  }
  overwrite   = true
}
resource "aws_ssm_parameter" "projecthoneypot_key" {
  name        = "/${var.app_env}/Deploy/${var.app_name}/projecthoneypot_key"
  type        = "SecureString"
  value       = var.projecthoneypot_key
  tags = {
    cost-center = "saas"
  }
  overwrite   = true
}
resource "aws_ssm_parameter" "whoisxmlapi_key" {
  name        = "/${var.app_env}/Deploy/${var.app_name}/whoisxmlapi_key"
  type        = "SecureString"
  value       = var.whoisxmlapi_key
  tags = {
    cost-center = "saas"
  }
  overwrite   = true
}
resource "aws_ssm_parameter" "domaintools_key" {
  name        = "/${var.app_env}/Deploy/${var.app_name}/domaintools_key"
  type        = "SecureString"
  value       = var.domaintools_key
  tags = {
    cost-center = "saas"
  }
  overwrite   = true
}
resource "aws_ssm_parameter" "domaintools_user" {
  name        = "/${var.app_env}/Deploy/${var.app_name}/domaintools_user"
  type        = "String"
  value       = var.domaintools_user
  tags = {
    cost-center = "saas"
  }
  overwrite   = true
}
resource "aws_ssm_parameter" "domainsdb_key" {
  name        = "/${var.app_env}/Deploy/${var.app_name}/domainsdb_key"
  type        = "SecureString"
  value       = var.domainsdb_key
  tags = {
    cost-center = "saas"
  }
  overwrite   = true
}
resource "aws_ssm_parameter" "phishtank_username" {
  name        = "/${var.app_env}/Deploy/${var.app_name}/phishtank_username"
  type        = "String"
  value       = var.phishtank_username
  tags = {
    cost-center = "saas"
  }
  overwrite   = true
}
resource "aws_ssm_parameter" "stripe_publishable_key" {
  name        = "/${var.app_env}/Deploy/${var.app_name}/stripe_publishable_key"
  type        = "String"
  value       = var.stripe_publishable_key
  tags = {
    cost-center = "saas"
  }
  overwrite   = true
}
resource "aws_ssm_parameter" "recaptcha_site_key" {
  name        = "/${var.app_env}/Deploy/${var.app_name}/recaptcha_site_key"
  type        = "String"
  value       = var.recaptcha_site_key
  tags = {
    cost-center = "saas"
  }
  overwrite   = true
}
