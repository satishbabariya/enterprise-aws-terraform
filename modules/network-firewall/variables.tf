variable "org_name" {
  description = "Short lowercase org name."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the firewall endpoints are deployed (typically a dedicated inspection VPC)."
  type        = string
}

variable "firewall_subnet_ids" {
  description = "Subnet IDs (one per AZ) where firewall endpoints will be placed."
  type        = list(string)
}

variable "domain_allowlist" {
  description = "Domains that egress is permitted to. Wildcard subdomains via .example.com syntax. Empty list means no allowlist enforcement."
  type        = list(string)
  default     = []
}

variable "enable_managed_rule_groups" {
  description = "Attach AWS-managed threat-intel rule groups."
  type        = bool
  default     = true
}

variable "log_destination_arn" {
  description = "Kinesis Firehose ARN or CloudWatch Logs ARN for firewall flow + alert logs."
  type        = string
}

variable "log_destination_type" {
  description = "S3, CloudWatchLogs, or KinesisDataFirehose"
  type        = string
  default     = "CloudWatchLogs"
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
