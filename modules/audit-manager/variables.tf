variable "org_name" {
  description = "Short lowercase org name."
  type        = string
}

variable "evidence_bucket_name" {
  description = "S3 bucket where Audit Manager evidence is delivered (typically log-archive)."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key for evidence encryption."
  type        = string
}

variable "delegated_admin_account_id" {
  description = "Security account ID acting as Audit Manager delegated admin."
  type        = string
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
