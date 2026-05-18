variable "org_name" {
  description = "Short lowercase org name."
  type        = string
}

variable "account_name" {
  description = "Short lowercase account name. Example: prod"
  type        = string
}

variable "region" {
  description = "AWS region."
  type        = string
}

variable "cidr_block" {
  description = "VPC CIDR. Example: 10.0.0.0/16"
  type        = string
  validation {
    condition     = can(cidrhost(var.cidr_block, 0))
    error_message = "cidr_block must be a valid CIDR."
  }
}

variable "availability_zones" {
  description = "List of 3 AZ names."
  type        = list(string)
  validation {
    condition     = length(var.availability_zones) == 3
    error_message = "Exactly 3 availability zones required."
  }
}

variable "public_subnet_cidrs" {
  description = "3 CIDRs for public subnets."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "3 CIDRs for private subnets."
  type        = list(string)
}

variable "isolated_subnet_cidrs" {
  description = "3 CIDRs for isolated (DB) subnets."
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Provision NAT gateways for private subnets."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use one NAT GW for all AZs (cost saving for non-prod)."
  type        = bool
  default     = false
}

variable "log_archive_bucket_arn" {
  description = "ARN of the centralized log archive bucket for VPC flow logs."
  type        = string
}

variable "flow_log_kms_key_arn" {
  description = "KMS key ARN for VPC flow log encryption."
  type        = string
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
