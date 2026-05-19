module "kms" {
  source      = "../kms"
  account_id  = var.account_id
  description = var.kms_key_description
  key_alias   = "${var.org_name}-${var.account_name}-general"
  tags        = var.tags
}

module "baseline" {
  source     = "../account-baseline"
  account_id = var.account_id
  tags       = var.tags
}

module "state_backend" {
  source                 = "../state-backend"
  org_name               = var.org_name
  account_name           = var.account_name
  region                 = var.region
  kms_key_arn            = module.kms.key_arn
  log_archive_bucket_arn = var.log_archive_bucket_arn
  tags                   = var.tags
}

module "secrets" {
  source       = "../secrets-baseline"
  org_name     = var.org_name
  account_name = var.account_name
  account_id   = var.account_id
  tags         = var.tags
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a3a8518e8759bf075b76b750d4f2df264fcd"]
}

resource "aws_iam_role" "terraform_ci" {
  name = "${var.org_name}-${var.account_name}-terraform-ci"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = aws_iam_openid_connect_provider.github.arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:*"
        }
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "terraform_ci" {
  role       = aws_iam_role.terraform_ci.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
