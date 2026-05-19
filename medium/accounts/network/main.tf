data "terraform_remote_state" "log_archive" {
  backend = "s3"
  config = {
    bucket = "${var.org_name}-us-east-1-tfstate"
    key    = "log-archive/terraform.tfstate"
    region = var.region
  }
}

module "kms" {
  source      = "../../../modules/kms"
  account_id  = var.network_account_id
  description = "Network account KMS key"
  key_alias   = "${var.org_name}-network-general"
}

module "baseline" {
  source     = "../../../modules/account-baseline"
  account_id = var.network_account_id
}

module "vpc" {
  source                 = "../../../modules/vpc"
  org_name               = var.org_name
  account_name           = "network"
  region                 = var.region
  cidr_block             = var.vpc_cidr
  availability_zones     = var.availability_zones
  public_subnet_cidrs    = var.public_subnet_cidrs
  private_subnet_cidrs   = var.private_subnet_cidrs
  isolated_subnet_cidrs  = var.isolated_subnet_cidrs
  enable_nat_gateway     = true
  single_nat_gateway     = false
  log_archive_bucket_arn = data.terraform_remote_state.log_archive.outputs.log_archive_bucket_arn
  flow_log_kms_key_arn   = module.kms.key_arn
}

module "tgw" {
  source              = "../../../modules/tgw-hub"
  org_name            = var.org_name
  allowed_cidr_blocks = [var.vpc_cidr]
}

module "private_zone" {
  source      = "../../../modules/route53"
  domain_name = "${var.org_name}.internal"
  vpc_id      = module.vpc.vpc_id
}
