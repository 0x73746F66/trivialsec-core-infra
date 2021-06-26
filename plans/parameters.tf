resource "aws_ssm_parameter" "mysql_password" {
  name        = "/${var.app_env}/Deploy/trivialsec/mysql_password"
  type        = "SecureString"
  value       = var.mysql_password
  tags = {
    cost-center = "saas"
  }
}
resource "aws_ssm_parameter" "session_secret_key" {
  name        = "/${var.app_env}/Deploy/trivialsec/session_secret_key"
  type        = "SecureString"
  value       = var.session_secret_key
  tags = {
    cost-center = "saas"
  }
}
resource "aws_ssm_parameter" "recaptcha_secret_key" {
  name        = "/${var.app_env}/Deploy/trivialsec/recaptcha_secret_key"
  type        = "SecureString"
  value       = var.recaptcha_secret_key
  tags = {
    cost-center = "saas"
  }
}
resource "aws_ssm_parameter" "sendgrid_api_key" {
  name        = "/${var.app_env}/Deploy/trivialsec/sendgrid_api_key"
  type        = "SecureString"
  value       = var.sendgrid_api_key
  tags = {
    cost-center = "saas"
  }
}
resource "aws_ssm_parameter" "stripe_secret_key" {
  name        = "/${var.app_env}/Deploy/trivialsec/stripe_secret_key"
  type        = "SecureString"
  value       = var.stripe_secret_key
  tags = {
    cost-center = "saas"
  }
}
resource "aws_ssm_parameter" "stripe_webhook_secret" {
  name        = "/${var.app_env}/Deploy/trivialsec/stripe_webhook_secret"
  type        = "SecureString"
  value       = var.stripe_webhook_secret
  tags = {
    cost-center = "saas"
  }
}
resource "aws_ssm_parameter" "google_api_key" {
  name        = "/${var.app_env}/Deploy/trivialsec/google_api_key"
  type        = "SecureString"
  value       = var.google_api_key
  tags = {
    cost-center = "saas"
  }
}
resource "aws_ssm_parameter" "phishtank_key" {
  name        = "/${var.app_env}/Deploy/trivialsec/phishtank_key"
  type        = "SecureString"
  value       = var.phishtank_key
  tags = {
    cost-center = "saas"
  }
}
resource "aws_ssm_parameter" "honeyscore_key" {
  name        = "/${var.app_env}/Deploy/trivialsec/honeyscore_key"
  type        = "SecureString"
  value       = var.honeyscore_key
  tags = {
    cost-center = "saas"
  }
}
resource "aws_ssm_parameter" "projecthoneypot_key" {
  name        = "/${var.app_env}/Deploy/trivialsec/projecthoneypot_key"
  type        = "SecureString"
  value       = var.projecthoneypot_key
  tags = {
    cost-center = "saas"
  }
}
resource "aws_ssm_parameter" "whoisxmlapi_key" {
  name        = "/${var.app_env}/Deploy/trivialsec/whoisxmlapi_key"
  type        = "SecureString"
  value       = var.whoisxmlapi_key
  tags = {
    cost-center = "saas"
  }
}
