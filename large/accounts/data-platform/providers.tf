provider "aws" {
  region = var.region

  assume_role {
    role_arn     = "arn:aws:iam::${var.account_id}:role/${var.org_name}-data-platform-terraform-ci"
    session_name = "terraform"
  }

  default_tags {
    tags = {
      Organization    = var.org_name
      Account         = "data-platform"
      Environment     = "shared"
      ManagedBy       = "terraform"
      Repository      = var.repo_url
      ComplianceScope = "all"
      DataClass       = "confidential"
    }
  }
}
