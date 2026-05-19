variable "org_name" {
  description = "Short lowercase org name."
  type        = string
}

variable "region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "repo_url" {
  description = "GitHub repo URL."
  type        = string
}

variable "account_id" {
  description = "Workload AWS account ID."
  type        = string
}

variable "account_name" {
  description = "Workload account name (prod, staging, dev, sandbox)."
  type        = string
}

variable "environment" {
  description = "Environment tag value."
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

variable "vpc_cidr" {
  description = "Workload VPC CIDR."
  type        = string
}

variable "availability_zones" {
  description = "AZs to deploy into."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs."
  type        = list(string)
}

variable "isolated_subnet_cidrs" {
  description = "Isolated subnet CIDRs."
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Enable NAT gateways."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT GW (cost saving for non-prod)."
  type        = bool
  default     = false
}
