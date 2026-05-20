################################################################################
# Global customizations - applied to every AFT-managed account.
#
# This file goes in your `aft-global-customizations` repo at:
#   terraform/baseline.tf
#
# AFT provides aft-managed Terraform variables:
#   - aft_request_metadata_account_name
#   - aft_request_metadata_account_email
#   - aft_request_metadata_account_type
#   - ct_management_account_id, log_archive_account_id, audit_account_id
#
# The provider is pre-configured by AFT to deploy into the target account.
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

# Pin to a commit SHA in production. Use main for development.
locals {
  template_ref = "main"
  template_src = "git::https://github.com/satishbabariya/enterprise-aws-terraform.git"

  # Pull these from your AFT settings (typically backed by SSM Parameter Store
  # or hardcoded in your global customizations).
  org_name                = "acme"
  log_archive_bucket_arn  = "arn:aws:s3:::acme-us-east-1-log-archive"
  log_archive_bucket_name = "acme-us-east-1-log-archive"
  github_org              = "acme"
  github_repo             = "infrastructure"
}

# Account-level security hardening - applies in every AFT account.
module "account_baseline" {
  source = "${local.template_src}//modules/account-baseline?ref=${local.template_ref}"

  account_id                 = data.aws_caller_identity.current.account_id
  monthly_budget_amount_usd  = 100
  budget_notification_emails = ["finance@${local.org_name}.com"]
}

# Per-account KMS key for general encryption (EBS, S3, RDS, etc.)
module "kms_general" {
  source = "${local.template_src}//modules/kms?ref=${local.template_ref}"

  account_id  = data.aws_caller_identity.current.account_id
  description = "General-purpose KMS key for this account"
  key_alias   = "${local.org_name}-general"
}

# Per-account Secrets Manager KMS key + rotation Lambda role
module "secrets_baseline" {
  source = "${local.template_src}//modules/secrets-baseline?ref=${local.template_ref}"

  org_name     = local.org_name
  account_name = lower(replace(var.aft_request_metadata_account_name, " ", "-"))
  account_id   = data.aws_caller_identity.current.account_id
}

# GitHub OIDC trust for CI/CD - every account gets a CI role assumable by
# the platform repo via GitHub Actions OIDC.
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a3a8518e8759bf075b76b750d4f2df264fcd"]
}

resource "aws_iam_role" "terraform_ci" {
  name = "${local.org_name}-terraform-ci"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = aws_iam_openid_connect_provider.github.arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = { "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com" }
        StringLike   = { "token.actions.githubusercontent.com:sub" = "repo:${local.github_org}/${local.github_repo}:*" }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "terraform_ci_admin" {
  role       = aws_iam_role.terraform_ci.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
