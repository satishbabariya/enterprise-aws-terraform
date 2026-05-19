variable "org_name" {
  description = "Short lowercase org name."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key for backup vault encryption."
  type        = string
}

variable "vault_lock_min_retention_days" {
  description = "Minimum retention enforced by Vault Lock. Set to 0 to disable Vault Lock (NOT recommended for prod)."
  type        = number
  default     = 365
}

variable "vault_lock_max_retention_days" {
  description = "Maximum retention enforced by Vault Lock."
  type        = number
  default     = 36500
}

variable "vault_lock_changeable_for_days" {
  description = "Cooling-off window (1-3 days) before Vault Lock becomes immutable. AWS minimum is 3. Set to 0 to skip Vault Lock entirely."
  type        = number
  default     = 3
}

variable "daily_backup_retention_days" {
  description = "How long to retain daily backups."
  type        = number
  default     = 35
}

variable "weekly_backup_retention_days" {
  description = "How long to retain weekly backups."
  type        = number
  default     = 365
}

variable "monthly_backup_retention_days" {
  description = "How long to retain monthly backups (regulatory archive)."
  type        = number
  default     = 2555 # 7 years
}

variable "cross_region_copy_destination" {
  description = "ARN of a backup vault in a secondary region for cross-region copies. Leave empty to disable."
  type        = string
  default     = ""
}

variable "backup_tag_key" {
  description = "Tag key used to select resources for backup. Resources tagged with this key are included."
  type        = string
  default     = "Backup"
}

variable "backup_tag_value" {
  description = "Tag value to match for backup selection."
  type        = string
  default     = "true"
}

variable "tags" {
  description = "Tags to apply."
  type        = map(string)
  default     = {}
}
