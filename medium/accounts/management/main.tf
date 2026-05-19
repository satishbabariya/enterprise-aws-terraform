module "kms" {
  source      = "../../../modules/kms"
  account_id  = var.management_account_id
  description = "Management account KMS key"
  key_alias   = "${var.org_name}-management-general"
  tags        = local.common_tags
}

module "organization" {
  source   = "../../../modules/aws-organization"
  org_name = var.org_name
  tags     = local.common_tags
}

module "scps" {
  source          = "../../../modules/scp-policies"
  allowed_regions = var.allowed_regions
  tags            = local.common_tags
}

resource "aws_organizations_policy_attachment" "deny_root_all_ous" {
  policy_id = module.scps.policy_ids["deny_root_actions"]
  target_id = module.organization.root_id
}

resource "aws_organizations_policy_attachment" "deny_leave_org" {
  policy_id = module.scps.policy_ids["deny_leave_org"]
  target_id = module.organization.root_id
}

resource "aws_organizations_policy_attachment" "deny_regions" {
  policy_id = module.scps.policy_ids["deny_regions"]
  target_id = module.organization.root_id
}

resource "aws_organizations_policy_attachment" "deny_unencrypted_workloads" {
  policy_id = module.scps.policy_ids["deny_unencrypted_storage"]
  target_id = module.organization.organizational_unit_ids["workloads"]
}

resource "aws_organizations_policy_attachment" "deny_iam_users_workloads" {
  policy_id = module.scps.policy_ids["deny_iam_user_creation"]
  target_id = module.organization.organizational_unit_ids["workloads"]
}

resource "aws_organizations_policy_attachment" "require_imdsv2_workloads" {
  policy_id = module.scps.policy_ids["require_imdsv2"]
  target_id = module.organization.organizational_unit_ids["workloads"]
}

module "identity_center" {
  source            = "../../../modules/identity-center"
  sso_instance_arn  = var.sso_instance_arn
  identity_store_id = var.identity_store_id
  tags              = local.common_tags
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a3a8518e8759bf075b76b750d4f2df264fcd"]
}

resource "aws_iam_role" "terraform_ci" {
  name = "${var.org_name}-management-terraform-ci"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = aws_iam_openid_connect_provider.github.arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = { "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com" }
        StringLike   = { "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:*" }
      }
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "terraform_ci" {
  role       = aws_iam_role.terraform_ci.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

data "terraform_remote_state" "log_archive" {
  backend = "s3"
  config = {
    bucket = "${var.org_name}-us-east-1-tfstate"
    key    = "log-archive/terraform.tfstate"
    region = var.region
  }
}

module "cloudtrail" {
  source                  = "../../../modules/cloudtrail"
  org_name                = var.org_name
  log_archive_bucket_name = data.terraform_remote_state.log_archive.outputs.log_archive_bucket_name
  kms_key_arn             = module.kms.key_arn
  tags                    = local.common_tags
}
