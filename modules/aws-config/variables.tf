variable "org_name" {
  description = "Short lowercase org name."
  type        = string
}

variable "account_id" {
  description = "AWS account ID."
  type        = string
}

variable "log_archive_bucket_name" {
  description = "Centralized log archive bucket name."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for Config snapshot encryption."
  type        = string
}

variable "org_aggregator_account_id" {
  description = "Security account ID that aggregates Config data."
  type        = string
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
