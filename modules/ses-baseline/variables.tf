variable "domain" {
  description = "Domain to verify for SES sending."
  type        = string
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID for var.domain - used to create DKIM CNAMEs automatically. Empty skips DNS setup (manual)."
  type        = string
  default     = ""
}

variable "mail_from_subdomain" {
  description = "Subdomain used as MAIL FROM (e.g., 'mail' creates mail.example.com). Empty disables custom MAIL FROM."
  type        = string
  default     = "mail"
}

variable "configuration_set_name" {
  description = "Name of the SES configuration set."
  type        = string
}

variable "bounce_complaint_topic_arn" {
  description = "SNS topic ARN to receive bounce and complaint notifications."
  type        = string
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
