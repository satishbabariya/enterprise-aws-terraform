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
  description = "Data platform account ID."
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
  default     = "172.17.0.0/16"
  description = "VPC CIDR."
}

variable "availability_zones" {
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
  description = "AZs."
}

variable "public_subnet_cidrs" {
  type        = list(string)
  default     = ["172.17.0.0/24", "172.17.1.0/24", "172.17.2.0/24"]
  description = "Public subnets."
}

variable "private_subnet_cidrs" {
  type        = list(string)
  default     = ["172.17.10.0/24", "172.17.11.0/24", "172.17.12.0/24"]
  description = "Private subnets."
}

variable "isolated_subnet_cidrs" {
  type        = list(string)
  default     = ["172.17.20.0/24", "172.17.21.0/24", "172.17.22.0/24"]
  description = "Isolated subnets."
}
