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

variable "enable_gateway_endpoints" {
  description = "Create Gateway endpoints (S3, DynamoDB). Free; no NAT bypass cost."
  type        = bool
  default     = true
}

variable "interface_endpoint_services" {
  description = <<-EOT
    Interface endpoint service short names to create (without 'com.amazonaws.<region>.' prefix).
    Each interface endpoint costs ~$7.20/month/AZ plus data charges, but avoids NAT bandwidth.
    Common picks: ssm, ssmmessages, ec2messages, ec2, kms, logs, secretsmanager,
    monitoring, sts, ecr.api, ecr.dkr.
  EOT
  type        = list(string)
  default = [
    "ssm",
    "ssmmessages",
    "ec2messages",
    "kms",
    "logs",
    "secretsmanager",
    "monitoring",
    "sts",
    "ecr.api",
    "ecr.dkr",
  ]
}

variable "eks_subnet_tags_enabled" {
  description = <<-EOT
    Add kubernetes.io/role/elb (public) and kubernetes.io/role/internal-elb (private)
    tags so the AWS Load Balancer Controller can auto-discover subnets. Required
    if this VPC hosts EKS workloads. Safe to leave on - costs nothing if no EKS.
  EOT
  type        = bool
  default     = true
}

variable "eks_cluster_names" {
  description = "EKS cluster names that should additionally tag subnets with kubernetes.io/cluster/<name> = shared. Required when sharing a VPC across multiple clusters."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
