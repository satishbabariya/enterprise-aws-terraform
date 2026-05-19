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
  account_name            = "data-platform"
  account_id              = var.account_id
  region                  = var.region
  log_archive_bucket_arn  = data.terraform_remote_state.log_archive.outputs.log_archive_bucket_arn
  log_archive_bucket_name = data.terraform_remote_state.log_archive.outputs.log_archive_bucket_name
  github_org              = var.github_org
  github_repo             = var.github_repo
}

module "vpc" {
  source                 = "../../../modules/vpc"
  org_name               = var.org_name
  account_name           = "data-platform"
  region                 = var.region
  cidr_block             = var.vpc_cidr
  availability_zones     = var.availability_zones
  public_subnet_cidrs    = var.public_subnet_cidrs
  private_subnet_cidrs   = var.private_subnet_cidrs
  isolated_subnet_cidrs  = var.isolated_subnet_cidrs
  enable_nat_gateway     = true
  single_nat_gateway     = true
  log_archive_bucket_arn = data.terraform_remote_state.log_archive.outputs.log_archive_bucket_arn
  flow_log_kms_key_arn   = module.workload_baseline.kms_key_arn
}

resource "aws_lakeformation_data_lake_settings" "this" {
  admins = [module.workload_baseline.terraform_ci_role_arn]
}
