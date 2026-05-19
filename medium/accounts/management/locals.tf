locals {
  org_name    = var.org_name
  region      = var.region
  repo_url    = var.repo_url
  github_org  = var.github_org
  github_repo = var.github_repo

  common_tags = {
    Organization    = local.org_name
    ManagedBy       = "terraform"
    Repository      = local.repo_url
    ComplianceScope = "all"
    DataClass       = "internal"
  }
}
