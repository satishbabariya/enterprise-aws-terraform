variable "org_name" {
  description = "Short lowercase org name."
  type        = string
}

variable "log_archive_bucket_name" {
  description = "Name of the centralized log-archive S3 bucket."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for CloudTrail log encryption."
  type        = string
}

variable "cloudwatch_log_group_arn" {
  description = "CloudWatch Logs group ARN for CloudTrail delivery. Leave empty to disable CW Logs delivery."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply."
  type        = map(string)
  default     = {}
}
