variable "delegated_admin_account_id" {
  description = "Account ID of the security account acting as GuardDuty delegated admin."
  type        = string
}

variable "finding_publishing_frequency" {
  description = "How often to publish findings. FIFTEEN_MINUTES, ONE_HOUR, or SIX_HOURS."
  type        = string
  default     = "SIX_HOURS"
  validation {
    condition     = contains(["FIFTEEN_MINUTES", "ONE_HOUR", "SIX_HOURS"], var.finding_publishing_frequency)
    error_message = "Must be FIFTEEN_MINUTES, ONE_HOUR, or SIX_HOURS."
  }
}

variable "auto_enable_org_members" {
  description = "Auto-enable GuardDuty for org members: ALL, NEW, or NONE."
  type        = string
  default     = "ALL"
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
