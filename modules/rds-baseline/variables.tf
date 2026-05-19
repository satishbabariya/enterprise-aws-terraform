variable "name" {
  description = "RDS instance identifier."
  type        = string
}

variable "engine" {
  description = "Database engine: postgres or mysql."
  type        = string
  validation {
    condition     = contains(["postgres", "mysql"], var.engine)
    error_message = "engine must be postgres or mysql."
  }
}

variable "engine_version" {
  description = "Engine version."
  type        = string
}

variable "instance_class" {
  description = "Instance class (e.g., db.r6g.large)."
  type        = string
}

variable "allocated_storage_gb" {
  description = "Allocated storage in GB."
  type        = number
  default     = 100
}

variable "max_allocated_storage_gb" {
  description = "Storage autoscaling max."
  type        = number
  default     = 1000
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "isolated_subnet_ids" {
  description = "Isolated subnet IDs for the DB subnet group."
  type        = list(string)
}

variable "allowed_security_group_ids" {
  description = "Security group IDs allowed to connect to this database."
  type        = list(string)
  default     = []
}

variable "kms_key_arn" {
  description = "KMS key ARN for storage + Performance Insights encryption."
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
  description = "Automated backup retention."
  type        = number
  default     = 30
}

variable "backup_window" {
  description = "Preferred backup window (UTC)."
  type        = string
  default     = "03:00-05:00"
}

variable "maintenance_window" {
  description = "Preferred maintenance window."
  type        = string
  default     = "Mon:05:00-Mon:07:00"
}

variable "multi_az" {
  description = "Multi-AZ deployment."
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Enable deletion protection."
  type        = bool
  default     = true
}

variable "iops" {
  description = "Provisioned IOPS for gp3/io1/io2. Null uses AWS default. For gp3, only set if > 3000 baseline IOPS needed."
  type        = number
  default     = null
}

variable "storage_throughput" {
  description = "Provisioned throughput in MB/s for gp3 storage. Null uses default (125 MB/s). Max 1000 MB/s."
  type        = number
  default     = null
}

variable "blue_green_update_enabled" {
  description = "Enable blue/green deployments for engine version upgrades - seconds of downtime instead of minutes."
  type        = bool
  default     = false
}

variable "allow_major_version_upgrade" {
  description = "Allow Terraform to perform major version upgrades. Disabled by default to prevent accidental cross-version migration."
  type        = bool
  default     = false
}

variable "apply_immediately" {
  description = "Apply modifications immediately instead of next maintenance window. Some changes still cause downtime."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
