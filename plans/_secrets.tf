variable "aws_secret_access_key" {
  description = "AWS_SECRET_ACCESS_KEY"
  type        = string
  sensitive   = true
}
variable "mysql_password" {
  description = "MYSQL_PASSWORD"
  type        = string
  sensitive   = true
}
variable "session_secret_key" {
  description = ""
  type        = string
  sensitive   = true
}
variable "recaptcha_secret_key" {
  description = ""
  type        = string
  sensitive   = true
}
variable "sendgrid_api_key" {
  description = ""
  type        = string
  sensitive   = true
}
variable "stripe_secret_key" {
  description = ""
  type        = string
  sensitive   = true
}
variable "stripe_webhook_secret" {
  description = ""
  type        = string
  sensitive   = true
}
variable "google_api_key" {
  description = ""
  type        = string
  sensitive   = true
}
variable "phishtank_key" {
  description = ""
  type        = string
  sensitive   = true
}
variable "honeyscore_key" {
  description = ""
  type        = string
  sensitive   = true
}
variable "projecthoneypot_key" {
  description = ""
  type        = string
  sensitive   = true
}
variable "whoisxmlapi_key" {
  description = ""
  type        = string
  sensitive   = true
}