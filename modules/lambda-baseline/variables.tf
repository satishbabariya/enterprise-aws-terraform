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

variable "layers" {
  description = "Lambda layer ARNs to attach (max 5). Caller-supplied layers will be combined with the Insights layer if enable_lambda_insights = true."
  type        = list(string)
  default     = []
  validation {
    condition     = length(var.layers) <= 5
    error_message = "Lambda supports at most 5 layers per function."
  }
}

variable "permissions_boundary_arn" {
  description = "IAM permissions boundary ARN for the execution role. Caps what additional policies the role can grant."
  type        = string
  default     = ""
}

variable "enable_lambda_insights" {
  description = "Attach the Lambda Insights extension layer (enhanced CloudWatch metrics: CPU, memory, network, disk)."
  type        = bool
  default     = false
}

variable "lambda_insights_layer_arn" {
  description = "Lambda Insights extension layer ARN. Region-specific - find at https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Cloudwatch-Lambda-Insights-extension-versions.html"
  type        = string
  default     = ""
}

variable "function_url_enabled" {
  description = "Create a Lambda Function URL (public HTTPS endpoint). Use AWS_IAM auth in any non-trivial case."
  type        = bool
  default     = false
}

variable "function_url_authorization_type" {
  description = "AWS_IAM (signed requests required) or NONE (public)."
  type        = string
  default     = "AWS_IAM"
  validation {
    condition     = contains(["AWS_IAM", "NONE"], var.function_url_authorization_type)
    error_message = "function_url_authorization_type must be AWS_IAM or NONE."
  }
}

variable "publish_version" {
  description = "Publish a new immutable version on each apply. Required for alias-based deployments."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
