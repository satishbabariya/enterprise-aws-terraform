variable "name" {
  description = "ECS cluster name."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key for CloudWatch log encryption + ECS Exec session encryption."
  type        = string
}

variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights."
  type        = bool
  default     = true
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
