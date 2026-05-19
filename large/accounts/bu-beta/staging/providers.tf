provider "aws" {
  region = var.region

  assume_role {
    role_arn     = "arn:aws:iam::${var.account_id}:role/${var.org_name}-${var.bu_name}-${var.env_name}-terraform-ci"
    session_name = "terraform"
  }

  default_tags {
    tags = {
      Organization    = var.org_name
      Account         = "${var.bu_name}-${var.env_name}"
      BusinessUnit    = var.bu_name
      Environment     = var.env_name
      ManagedBy       = "terraform"
      Repository      = var.repo_url
      ComplianceScope = "all"
      DataClass       = "internal"
    }
  }
}
