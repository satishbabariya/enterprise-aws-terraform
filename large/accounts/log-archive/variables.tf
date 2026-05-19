variable "org_name" {
  description = "Short lowercase org name."
  type        = string
}

variable "region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "repo_url" {
  description = "GitHub repo URL."
  type        = string
}

variable "org_id" {
  description = "AWS Organizations organization ID."
  type        = string
}

variable "log_archive_account_id" {
  description = "Log archive account ID."
  type        = string
}

variable "management_account_id" {
  description = "Management account ID."
  type        = string
}

variable "object_lock_retention_days" {
  description = "WORM retention in days."
  type        = number
  default     = 365
}

variable "security_account_id" {
  description = "Security account ID - granted assume permission on the AuditReader role."
  type        = string
}

variable "audit_reader_external_id" {
  description = "Optional external ID required when assuming the AuditReader role (defense in depth)."
  type        = string
  default     = ""
}
