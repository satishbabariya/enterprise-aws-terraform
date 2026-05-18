variable "org_name" {
  description = "Short lowercase org name. Example: acme"
  type        = string
}

variable "account_name" {
  description = "Short lowercase account name. Example: prod"
  type        = string
}

variable "region" {
  description = "AWS region for the bucket and table."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN to encrypt the state bucket and DynamoDB table."
  type        = string
}

variable "log_archive_bucket_arn" {
  description = "ARN of the centralized log archive bucket for S3 access logging."
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default     = {}
}
