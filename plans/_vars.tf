variable "aws_access_key_id" {
  description = "AWS_ACCESS_KEY_ID"
  type        = string
}
variable "app_env" {
  description = "default Dev"
  type        = string
  default     = "Dev"
}
variable "app_name" {
  description = "default trivialsec"
  type        = string
  default     = "trivialsec"
}
variable "recaptcha_site_key" {
  description = ""
  type        = string
}
variable "stripe_publishable_key" {
  description = ""
  type        = string
}
variable "phishtank_username" {
  description = ""
  type        = string
}
