variable "org_name" {
  description = "Short lowercase org name."
  type        = string
}

variable "log_archive_bucket_name" {
  description = "Name of the centralized log archive S3 bucket."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key for query result encryption."
  type        = string
}

variable "athena_results_bucket_name" {
  description = "Optional S3 bucket for Athena query results. If empty, a new bucket is created."
  type        = string
  default     = ""
}

variable "query_result_retention_days" {
  description = "How long to retain Athena query results."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
