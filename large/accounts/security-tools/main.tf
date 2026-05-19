data "terraform_remote_state" "log_archive" {
  backend = "s3"
  config = {
    bucket = "${var.org_name}-us-east-1-tfstate"
    key    = "large/log-archive/terraform.tfstate"
    region = var.region
  }
}

module "workload_baseline" {
  source                  = "../../../modules/workload-baseline"
  org_name                = var.org_name
  account_name            = "security-tools"
  account_id              = var.account_id
  region                  = var.region
  log_archive_bucket_arn  = data.terraform_remote_state.log_archive.outputs.log_archive_bucket_arn
  log_archive_bucket_name = data.terraform_remote_state.log_archive.outputs.log_archive_bucket_name
  github_org              = var.github_org
  github_repo             = var.github_repo
}
