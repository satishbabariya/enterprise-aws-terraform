variable "delegated_admin_account_id" {
  description = "Security account ID that becomes Macie delegated admin."
  type        = string
}

variable "finding_publishing_frequency" {
  description = "How often to publish findings."
  type        = string
  default     = "SIX_HOURS"
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
