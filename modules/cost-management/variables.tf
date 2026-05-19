variable "org_name" {
  description = "Short lowercase org name."
  type        = string
}

variable "cur_bucket_name" {
  description = "S3 bucket name to receive the Cost & Usage Report. Should live in the log-archive account."
  type        = string
}

variable "cur_bucket_region" {
  description = "Region of the CUR bucket."
  type        = string
  default     = "us-east-1"
}

variable "anomaly_alert_topic_arn" {
  description = "SNS topic ARN where Cost Anomaly Detection sends alerts."
  type        = string
}

variable "monthly_org_budget_usd" {
  description = "Org-wide monthly cost budget in USD."
  type        = number
  default     = 50000
}

variable "budget_notification_emails" {
  description = "Emails to notify on org-budget threshold breach."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
