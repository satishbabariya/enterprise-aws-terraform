variable "org_name" {
  type        = string
  description = "Org name."
}

variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region."
}

variable "repo_url" {
  type        = string
  description = "GitHub repo URL."
}

variable "account_id" {
  type        = string
  description = "Workload account ID."
}

variable "bu_name" {
  type        = string
  description = "Business unit name, e.g. bu-alpha."
}

variable "env_name" {
  type        = string
  description = "Environment name, e.g. prod."
}

variable "github_org" {
  type        = string
  description = "GitHub org name."
}

variable "github_repo" {
  type        = string
  description = "GitHub repo name."
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR."
}

variable "availability_zones" {
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
  description = "AZs."
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public subnet CIDRs."
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private subnet CIDRs."
}

variable "isolated_subnet_cidrs" {
  type        = list(string)
  description = "Isolated subnet CIDRs."
}

variable "single_nat_gateway" {
  type        = bool
  default     = false
  description = "Use single NAT GW."
}
