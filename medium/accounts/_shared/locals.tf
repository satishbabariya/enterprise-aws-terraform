# Copy into each account root as locals.tf and customize.
locals {
  org_name    = "acme"
  region      = "us-east-1"
  repo_url    = "https://github.com/acme/enterprise-aws-terraform"
  github_org  = "acme"
  github_repo = "enterprise-aws-terraform"

  # Management/foundation account references (update after each account is applied)
  management_account_id   = "111111111111"
  log_archive_bucket_name = "acme-us-east-1-log-archive"
  log_archive_bucket_arn  = "arn:aws:s3:::acme-us-east-1-log-archive"
  security_account_id     = "222222222222"
  network_account_id      = "333333333333"

  common_tags = {
    Organization = local.org_name
    ManagedBy    = "terraform"
    Repository   = local.repo_url
  }
}
