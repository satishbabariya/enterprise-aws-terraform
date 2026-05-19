variable "name" {
  description = "User pool name."
  type        = string
}

variable "mfa_configuration" {
  description = "OFF, ON, or OPTIONAL"
  type        = string
  default     = "ON"
}

variable "password_minimum_length" {
  description = "Minimum password length."
  type        = number
  default     = 14
}

variable "advanced_security_mode" {
  description = "OFF, AUDIT, or ENFORCED. ENFORCED enables compromised-credentials checks + risk-based auth."
  type        = string
  default     = "ENFORCED"
}

variable "deletion_protection" {
  description = "ACTIVE or INACTIVE"
  type        = string
  default     = "ACTIVE"
}

variable "callback_urls" {
  description = "Allowed OAuth callback URLs."
  type        = list(string)
  default     = []
}

variable "logout_urls" {
  description = "Allowed OAuth logout URLs."
  type        = list(string)
  default     = []
}

variable "ses_source_arn" {
  description = "Verified SES identity ARN for sending Cognito emails. Empty uses default Cognito sender (rate-limited)."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
