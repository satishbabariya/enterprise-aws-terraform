variable "org_name" {
  description = "Short lowercase org name."
  type        = string
}

variable "account_name" {
  description = "Short lowercase account name."
  type        = string
}

variable "account_id" {
  description = "AWS account ID."
  type        = string
}

variable "region" {
  description = "AWS region."
  type        = string
}

variable "log_archive_bucket_arn" {
  description = "ARN of the centralized log archive bucket."
  type        = string
}

variable "log_archive_bucket_name" {
  description = "Name of the centralized log archive bucket."
  type        = string
}

variable "kms_key_description" {
  description = "Description for the workload's general-purpose KMS key."
  type        = string
  default     = "Workload account general-purpose KMS key"
}

variable "github_org" {
  description = "GitHub org name for OIDC trust."
  type        = string
}

variable "github_repo" {
  description = "GitHub repo name for OIDC trust."
  type        = string
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
