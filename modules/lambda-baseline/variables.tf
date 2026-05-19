variable "name" {
  description = "Lambda function name."
  type        = string
}

variable "handler" {
  description = "Function handler (e.g., index.handler)."
  type        = string
}

variable "runtime" {
  description = "Function runtime."
  type        = string
  default     = "python3.12"
}

variable "filename" {
  description = "Path to the deployment package zip on the executor filesystem. Use null when source_image is set."
  type        = string
  default     = null
}

variable "image_uri" {
  description = "ECR image URI for container Lambda. Empty for zip-based."
  type        = string
  default     = ""
}

variable "memory_size" {
  description = "Memory in MB."
  type        = number
  default     = 512
}

variable "timeout" {
  description = "Timeout in seconds."
  type        = number
  default     = 30
}

variable "architectures" {
  description = "x86_64 or arm64"
  type        = list(string)
  default     = ["arm64"]
}

variable "environment_variables" {
  description = "Environment variables. Sensitive values should reference Secrets Manager via AWS Lambda extensions."
  type        = map(string)
  default     = {}
}

variable "kms_key_arn" {
  description = "KMS key for environment variable encryption + log encryption."
  type        = string
}

variable "vpc_subnet_ids" {
  description = "Private subnet IDs. Empty to run outside a VPC."
  type        = list(string)
  default     = []
}

variable "vpc_security_group_ids" {
  description = "Security group IDs. Required if vpc_subnet_ids is set."
  type        = list(string)
  default     = []
}

variable "log_retention_days" {
  description = "Log retention."
  type        = number
  default     = 365
}

variable "reserved_concurrent_executions" {
  description = "Concurrency reservation. -1 for unreserved."
  type        = number
  default     = -1
}

variable "dead_letter_topic_arn" {
  description = "SNS topic to receive async invocation failures."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
