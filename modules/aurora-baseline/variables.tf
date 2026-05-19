variable "name" {
  description = "Aurora cluster identifier."
  type        = string
}

variable "engine" {
  description = "aurora-postgresql or aurora-mysql"
  type        = string
  validation {
    condition     = contains(["aurora-postgresql", "aurora-mysql"], var.engine)
    error_message = "engine must be aurora-postgresql or aurora-mysql."
  }
}

variable "engine_version" {
  description = "Engine version."
  type        = string
}

variable "instance_count" {
  description = "Number of cluster instances (writers + readers)."
  type        = number
  default     = 2
}

variable "instance_class" {
  description = "Instance class."
  type        = string
  default     = "db.r6g.large"
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "isolated_subnet_ids" {
  description = "Isolated subnet IDs."
  type        = list(string)
}

variable "allowed_security_group_ids" {
  description = "Security groups allowed to connect."
  type        = list(string)
  default     = []
}

variable "kms_key_arn" {
  description = "KMS key for storage encryption."
  type        = string
}

variable "db_name" {
  description = "Initial database name."
  type        = string
}

variable "master_username" {
  description = "Master username."
  type        = string
  default     = "dbadmin"
}

variable "backup_retention_days" {
  description = "Backup retention."
  type        = number
  default     = 30
}

variable "deletion_protection" {
  description = "Deletion protection."
  type        = bool
  default     = true
}

variable "enable_rds_proxy" {
  description = <<-EOT
    Provision RDS Proxy in front of the cluster. Connection pooling + IAM auth +
    faster failover (seconds vs tens of seconds). Critical for Lambda/serverless.
    Costs ~$0.015/vCPU-hour per node behind the proxy.
  EOT
  type        = bool
  default     = false
}

variable "rds_proxy_idle_client_timeout_seconds" {
  description = "Seconds an idle proxy client can hold a connection before recycling."
  type        = number
  default     = 1800
}

variable "rds_proxy_require_tls" {
  description = "Require TLS between clients and proxy."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
