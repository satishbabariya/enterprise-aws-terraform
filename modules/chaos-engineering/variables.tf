variable "org_name" {
  description = "Short lowercase org name."
  type        = string
}

variable "experiment_target_tag_key" {
  description = "Resources tagged with this key are eligible for chaos experiments."
  type        = string
  default     = "ChaosEligible"
}

variable "experiment_target_tag_value" {
  description = "Tag value matching for chaos eligibility."
  type        = string
  default     = "true"
}

variable "stop_condition_alarm_arns" {
  description = "CloudWatch alarm ARNs that will halt running experiments if breached."
  type        = list(string)
  default     = []
}

variable "log_group_arn" {
  description = "CloudWatch log group for FIS experiment logs."
  type        = string
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
