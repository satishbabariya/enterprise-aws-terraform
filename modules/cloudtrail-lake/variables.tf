variable "org_name" {
  description = "Short lowercase org name."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key for event data store encryption."
  type        = string
}

variable "retention_days" {
  description = "Event retention period in days. 7-year regulatory archive = 2555."
  type        = number
  default     = 2555
  validation {
    condition     = var.retention_days >= 7 && var.retention_days <= 3650
    error_message = "retention_days must be between 7 and 3650 (max 10 years)."
  }
}

variable "is_organization_event_data_store" {
  description = "Capture events from all accounts in the organization (recommended for centralized audit)."
  type        = bool
  default     = true
}

variable "include_management_events" {
  description = "Include management events (control plane API calls)."
  type        = bool
  default     = true
}

variable "include_s3_data_events" {
  description = "Include S3 object-level events (significant storage cost)."
  type        = bool
  default     = false
}

variable "include_lambda_data_events" {
  description = "Include Lambda invoke events."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
