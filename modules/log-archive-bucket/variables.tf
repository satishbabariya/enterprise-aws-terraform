variable "org_name" {
  description = "Short lowercase org name."
  type        = string
}

variable "region" {
  description = "AWS region."
  type        = string
}

variable "org_id" {
  description = "AWS Organizations organization ID. Used to scope the bucket policy."
  type        = string
}

variable "management_account_id" {
  description = "Management account ID - allowed to read and manage the bucket."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for bucket encryption."
  type        = string
}

variable "object_lock_retention_days" {
  description = "WORM retention period in days. Minimum 365 for PCI-DSS/HIPAA."
  type        = number
  default     = 365
  validation {
    condition     = var.object_lock_retention_days >= 365
    error_message = "Retention must be at least 365 days for PCI-DSS and HIPAA compliance."
  }
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
