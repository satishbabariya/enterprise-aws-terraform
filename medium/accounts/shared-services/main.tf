data "terraform_remote_state" "log_archive" {
  backend = "s3"
  config = {
    bucket = "${var.org_name}-us-east-1-tfstate"
    key    = "log-archive/terraform.tfstate"
    region = var.region
  }
}

module "workload_baseline" {
  source                  = "../../../modules/workload-baseline"
  org_name                = var.org_name
  account_name            = "shared-services"
  account_id              = var.shared_services_account_id
  region                  = var.region
  log_archive_bucket_arn  = data.terraform_remote_state.log_archive.outputs.log_archive_bucket_arn
  log_archive_bucket_name = data.terraform_remote_state.log_archive.outputs.log_archive_bucket_name
  github_org              = var.github_org
  github_repo             = var.github_repo
}

resource "aws_ecr_registry_scanning_configuration" "this" {
  scan_type = "ENHANCED"
  rule {
    scan_frequency = "CONTINUOUS_SCAN"
    repository_filter {
      filter      = "*"
      filter_type = "WILDCARD"
    }
  }
}

resource "aws_ecr_registry_policy" "org_pull" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowOrgPull"
      Effect    = "Allow"
      Principal = { AWS = "*" }
      Action = [
        "ecr:GetDownloadUrlForLayer", "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability", "ecr:GetAuthorizationToken"
      ]
      Resource = "*"
      Condition = {
        StringEquals = { "aws:PrincipalOrgID" = var.org_id }
      }
    }]
  })
}
