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

variable "replica_bucket_arn" {
  description = <<-EOT
    ARN of a destination bucket in a secondary region for cross-region replication.
    Must exist (create with a second copy of this module in the secondary region first,
    or pass a pre-existing replica bucket). Empty disables replication.
  EOT
  type        = string
  default     = ""
}

variable "replica_kms_key_arn" {
  description = "KMS key ARN in the destination region for encrypting replicated objects. Required if replica_bucket_arn is set."
  type        = string
  default     = ""
}

variable "audit_reader_principal_arns" {
  description = <<-EOT
    IAM principals (typically the security account's audit role ARN, or an SSO
    permission set role pattern) that can assume the AuditReader role to query
    archived logs read-only. Empty list disables the role creation.
    Example: ["arn:aws:iam::222222222222:root"]
  EOT
  type        = list(string)
  default     = []
}

variable "audit_reader_external_id" {
  description = "Optional external ID required by the AuditReader trust policy (defense in depth for cross-account trust). Empty disables."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
