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

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
