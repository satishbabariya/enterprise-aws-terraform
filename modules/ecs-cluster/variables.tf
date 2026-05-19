variable "name" {
  description = "ECS cluster name."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key for CloudWatch log encryption + ECS Exec session encryption."
  type        = string
}

variable "container_insights_mode" {
  description = <<-EOT
    Container Insights mode:
    - "enhanced" - newer mode (Nov 2024+) with per-task/service granularity + Application Signals support
    - "enabled"  - legacy mode (cluster-level metrics only)
    - "disabled" - off
    Enhanced is recommended for prod - the data is what you need during incident response.
  EOT
  type        = string
  default     = "enhanced"
  validation {
    condition     = contains(["enhanced", "enabled", "disabled"], var.container_insights_mode)
    error_message = "container_insights_mode must be enhanced, enabled, or disabled."
  }
}

variable "fargate_capacity_providers" {
  description = "Use FARGATE and/or FARGATE_SPOT."
  type        = list(string)
  default     = ["FARGATE", "FARGATE_SPOT"]
}

variable "log_retention_days" {
  description = "Cluster log group retention."
  type        = number
  default     = 365
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
