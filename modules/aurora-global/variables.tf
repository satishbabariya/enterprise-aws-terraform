variable "global_name" {
  description = "Global cluster identifier."
  type        = string
}

variable "engine" {
  description = "aurora-postgresql or aurora-mysql"
  type        = string
}

variable "engine_version" {
  description = "Engine version. Must be a Global Database-supported version."
  type        = string
}

variable "primary_cluster_identifier" {
  description = "Cluster identifier for the primary writer cluster."
  type        = string
}

variable "secondary_cluster_identifier" {
  description = "Cluster identifier for the secondary (read-only) cluster."
  type        = string
}

variable "primary_db_subnet_group_name" {
  description = "Existing DB subnet group in the primary region."
  type        = string
}

variable "secondary_db_subnet_group_name" {
  description = "Existing DB subnet group in the secondary region."
  type        = string
}

variable "primary_vpc_security_group_ids" {
  description = "Security groups in the primary region cluster."
  type        = list(string)
}

variable "secondary_vpc_security_group_ids" {
  description = "Security groups in the secondary region cluster."
  type        = list(string)
}

variable "primary_kms_key_arn" {
  description = "KMS key ARN in the primary region."
  type        = string
}

variable "secondary_kms_key_arn" {
  description = "KMS key ARN in the secondary region (must be a key in that region)."
  type        = string
}

variable "instance_count_per_region" {
  description = "Number of instances per region cluster."
  type        = number
  default     = 2
}

variable "instance_class" {
  description = "DB instance class."
  type        = string
  default     = "db.r6g.large"
}

variable "database_name" {
  description = "Initial DB name."
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
