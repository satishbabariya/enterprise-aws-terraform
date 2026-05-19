provider "aws" {
  region = var.region

  assume_role {
    role_arn     = "arn:aws:iam::${var.log_archive_account_id}:role/${var.org_name}-log-archive-terraform-ci"
    session_name = "terraform"
  }

  default_tags {
    tags = {
      Organization    = var.org_name
      Account         = "log-archive"
      Environment     = "management"
      ManagedBy       = "terraform"
      Repository      = var.repo_url
      ComplianceScope = "all"
      DataClass       = "internal"
    }
  }
}
