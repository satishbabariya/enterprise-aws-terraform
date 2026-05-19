variable "org_name" {
  description = "Short lowercase org name."
  type        = string
}

variable "log_archive_bucket_name" {
  description = "Name of the centralized log-archive S3 bucket."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for CloudTrail log encryption (primary region key, or multi-region key primary ARN)."
  type        = string
}

variable "enable_cloudwatch_logs" {
  description = "Create a CloudWatch log group + IAM role and ship trail events to it. Required for CIS metric filter alarms."
  type        = bool
  default     = true
}

variable "cloudwatch_log_retention_days" {
  description = "Retention for the trail's CloudWatch log group."
  type        = number
  default     = 365
}

variable "cloudwatch_log_group_class" {
  description = "Log group storage class: STANDARD or INFREQUENT_ACCESS. IA is ~50% cheaper for archive logs that are rarely queried in real time."
  type        = string
  default     = "STANDARD"
  validation {
    condition     = contains(["STANDARD", "INFREQUENT_ACCESS"], var.cloudwatch_log_group_class)
    error_message = "cloudwatch_log_group_class must be STANDARD or INFREQUENT_ACCESS."
  }
}

variable "alarms_sns_topic_arn" {
  description = "SNS topic to receive CIS metric filter alarms (typically the central 'high' severity topic). Empty disables alarm wiring."
  type        = string
  default     = ""
}

variable "enable_delivery_notification" {
  description = "Create an SNS topic that CloudTrail publishes log-file-delivery notifications to (for SIEM integrations)."
  type        = bool
  default     = false
}

variable "enable_eventbridge_remediation" {
  description = "Create EventBridge rules that route specific CloudTrail events (public SG ingress, IAM key creation) for downstream auto-remediation."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply."
  type        = map(string)
  default     = {}
}
