variable "org_name" {
  description = "Short lowercase org name."
  type        = string
}

variable "kms_key_id" {
  description = "KMS key ID for SNS topic encryption."
  type        = string
}

variable "severities" {
  description = "Severity tiers to create SNS topics for."
  type        = list(string)
  default     = ["critical", "high", "medium", "low", "info"]
}

variable "pagerduty_critical_endpoint" {
  description = "PagerDuty integration URL for the critical-severity topic. Empty disables."
  type        = string
  default     = ""
}

variable "pagerduty_high_endpoint" {
  description = "PagerDuty integration URL for the high-severity topic. Empty disables."
  type        = string
  default     = ""
}

variable "slack_workspace_id" {
  description = "AWS Chatbot workspace ID for Slack integration. Empty disables Chatbot setup. Run 'aws chatbot describe-slack-workspaces' to get this."
  type        = string
  default     = ""
}

variable "slack_channel_id" {
  description = "Slack channel ID to receive non-critical notifications."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
