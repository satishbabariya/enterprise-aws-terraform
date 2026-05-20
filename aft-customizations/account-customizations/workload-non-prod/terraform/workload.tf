################################################################################
# Per-account-type customization: workload-non-prod (dev / staging / sandbox)
#
# Cheaper variants of the prod baseline: single NAT gateway, shorter log
# retention, no deletion protection on data resources.
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

  org_name               = "acme"
  log_archive_bucket_arn = "arn:aws:s3:::acme-us-east-1-log-archive"

  account_name = lower(replace(var.aft_request_metadata_account_name, " ", "-"))
}

data "aws_kms_key" "general" {
  key_id = "alias/${local.org_name}-general"
}

# Non-prod VPC: single NAT gateway saves ~$64/month per account.
module "vpc" {
  source = "${local.template_src}//modules/vpc?ref=${local.template_ref}"

  org_name              = local.org_name
  account_name          = local.account_name
  region                = data.aws_region.current.name
  cidr_block            = lookup(var.workload_cidrs, local.account_name, "10.200.0.0/16")
  availability_zones    = ["${data.aws_region.current.name}a", "${data.aws_region.current.name}b", "${data.aws_region.current.name}c"]
  public_subnet_cidrs   = ["10.200.0.0/24", "10.200.1.0/24", "10.200.2.0/24"]
  private_subnet_cidrs  = ["10.200.10.0/24", "10.200.11.0/24", "10.200.12.0/24"]
  isolated_subnet_cidrs = ["10.200.20.0/24", "10.200.21.0/24", "10.200.22.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true # cost saving for non-prod

  log_archive_bucket_arn = local.log_archive_bucket_arn
  flow_log_kms_key_arn   = data.aws_kms_key.general.arn

  # Skip interface endpoints in non-prod - costs ~$220/account/month otherwise.
  interface_endpoint_services = []
}
