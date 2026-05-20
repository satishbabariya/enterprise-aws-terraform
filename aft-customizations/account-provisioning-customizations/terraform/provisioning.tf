################################################################################
# Account-provisioning customizations
#
# Runs as a Step Function DURING Control Tower account creation, before the
# global + account customization Terraform pipelines kick off. Use this for
# things that must exist before any later Terraform runs.
#
# AFT's default just enrolls the account; this file extends it with:
#   - account-level password policy
#   - default EBS encryption
#   - default VPC deletion
#   - IMDSv2 default
#
# All of these are also enforced by SCPs at the org level, but having them
# locally configured prevents the brief window where a new account is
# vended but its account-level controls haven't been applied yet.
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

module "account_baseline" {
  source = "git::https://github.com/satishbabariya/enterprise-aws-terraform.git//modules/account-baseline?ref=main"

  account_id                 = data.aws_caller_identity.current.account_id
  monthly_budget_amount_usd  = 50
  budget_notification_emails = []
}
