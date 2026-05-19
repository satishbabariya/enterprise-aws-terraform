provider "aws" {
  region = var.region

  assume_role {
    role_arn     = "arn:aws:iam::${var.network_account_id}:role/${var.org_name}-network-terraform-ci"
    session_name = "terraform"
  }

  default_tags {
    tags = {
      Organization    = var.org_name
      Account         = "network"
      Environment     = "shared"
      ManagedBy       = "terraform"
      Repository      = var.repo_url
      ComplianceScope = "all"
      DataClass       = "internal"
    }
  }
}
