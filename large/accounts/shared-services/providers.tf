provider "aws" {
  region = var.region

  assume_role {
    role_arn     = "arn:aws:iam::${var.shared_services_account_id}:role/${var.org_name}-shared-services-terraform-ci"
    session_name = "terraform"
  }

  default_tags {
    tags = {
      Organization    = var.org_name
      Account         = "shared-services"
      Environment     = "shared"
      ManagedBy       = "terraform"
      Repository      = var.repo_url
      ComplianceScope = "all"
      DataClass       = "internal"
    }
  }
}
