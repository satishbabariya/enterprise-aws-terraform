variable "org_name" {
  description = "Short lowercase org name."
  type        = string
}

variable "region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "account_id" {
  description = "AWS account ID where this workload deploys."
  type        = string
}

variable "account_name" {
  description = "Account name (e.g., prod, staging)."
  type        = string
}

variable "environment" {
  description = "Environment tag."
  type        = string
}

variable "repo_url" {
  description = "GitHub repo URL."
  type        = string
}

variable "github_org" {
  description = "GitHub org name."
  type        = string
}

variable "github_repo" {
  description = "GitHub repo name."
  type        = string
}

variable "cost_center" {
  description = "Cost center tag."
  type        = string
}

variable "log_archive_bucket_arn" {
  description = "ARN of the centralized log archive bucket."
  type        = string
}

variable "log_archive_bucket_name" {
  description = "Name of the centralized log archive bucket."
  type        = string
}

variable "app_name" {
  description = "Application name (used in resource naming)."
  type        = string
  default     = "sample-app"
}

variable "app_image" {
  description = "ECR image URI (e.g., 123456789012.dkr.ecr.us-east-1.amazonaws.com/sample-app:abc123)."
  type        = string
}

variable "app_port" {
  description = "Port the container listens on."
  type        = number
  default     = 8080
}

variable "app_cpu" {
  description = "Fargate task CPU units (256, 512, 1024, 2048, 4096)."
  type        = number
  default     = 512
}

variable "app_memory" {
  description = "Fargate task memory (MB)."
  type        = number
  default     = 1024
}

variable "app_desired_count" {
  description = "Number of ECS tasks to run."
  type        = number
  default     = 2
}

variable "domain_name" {
  description = "Public domain name (e.g., app.example.com). The ACM cert must already exist for this domain."
  type        = string
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for the ALB HTTPS listener."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR for this workload."
  type        = string
  default     = "10.50.0.0/16"
}
