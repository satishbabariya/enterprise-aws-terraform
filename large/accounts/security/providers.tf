provider "aws" {
  region = var.region

  assume_role {
    role_arn     = "arn:aws:iam::${var.security_account_id}:role/${var.org_name}-security-terraform-ci"
    session_name = "terraform"
  }

  default_tags {
    tags = {
      Organization    = var.org_name
      Account         = "security"
      Environment     = "management"
      ManagedBy       = "terraform"
      Repository      = var.repo_url
      ComplianceScope = "all"
      DataClass       = "internal"
    }
  }
}
