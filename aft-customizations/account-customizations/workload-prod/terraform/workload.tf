################################################################################
# Per-account-type customization: workload-prod
#
# Applied to AFT accounts requested with custom_fields.account_type = "workload-prod".
# Runs AFTER global-customizations. Provider is configured for the target account.
#
# Picks production defaults: multi-AZ NAT, deletion protection on, longer
# log retention, ECS cluster + Aurora baseline.
################################################################################

terraform {
  required_version = ">= 1.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  template_ref = "main"
  template_src = "git::https://github.com/satishbabariya/enterprise-aws-terraform.git"

  org_name                = "acme"
  log_archive_bucket_arn  = "arn:aws:s3:::acme-us-east-1-log-archive"
  log_archive_bucket_name = "acme-us-east-1-log-archive"

  account_name = lower(replace(var.aft_request_metadata_account_name, " ", "-"))
}

# General-purpose KMS already exists from global-customizations; reference it.
data "aws_kms_key" "general" {
  key_id = "alias/${local.org_name}-general"
}

# Production-grade VPC: 3-tier, multi-AZ NAT, full interface endpoints,
# EKS subnet tags so ALB Controller can auto-discover.
module "vpc" {
  source = "${local.template_src}//modules/vpc?ref=${local.template_ref}"

  org_name              = local.org_name
  account_name          = local.account_name
  region                = data.aws_region.current.name
  cidr_block            = lookup(var.workload_cidrs, local.account_name, "10.100.0.0/16")
  availability_zones    = ["${data.aws_region.current.name}a", "${data.aws_region.current.name}b", "${data.aws_region.current.name}c"]
  public_subnet_cidrs   = ["10.100.0.0/24", "10.100.1.0/24", "10.100.2.0/24"]
  private_subnet_cidrs  = ["10.100.10.0/24", "10.100.11.0/24", "10.100.12.0/24"]
  isolated_subnet_cidrs = ["10.100.20.0/24", "10.100.21.0/24", "10.100.22.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = false # multi-AZ NAT for prod resilience

  log_archive_bucket_arn = local.log_archive_bucket_arn
  flow_log_kms_key_arn   = data.aws_kms_key.general.arn

  eks_subnet_tags_enabled = true
}
