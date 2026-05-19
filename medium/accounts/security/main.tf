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
  account_id  = var.security_account_id
  description = "Security account KMS key"
  key_alias   = "${var.org_name}-security-general"
}

module "baseline" {
  source     = "../../../modules/account-baseline"
  account_id = var.security_account_id
}

module "security_hub" {
  source                   = "../../../modules/security-hub"
  enable_cis_standard      = true
  enable_pci_standard      = true
  enable_nist_standard     = true
  auto_enable_new_accounts = true
}

module "guardduty" {
  source                       = "../../../modules/guardduty"
  delegated_admin_account_id   = var.security_account_id
  finding_publishing_frequency = "SIX_HOURS"
}

module "macie" {
  source                     = "../../../modules/macie"
  delegated_admin_account_id = var.security_account_id
}

module "access_analyzer" {
  source        = "../../../modules/access-analyzer"
  org_name      = var.org_name
  analyzer_type = "ORGANIZATION"
}

module "inspector" {
  source                     = "../../../modules/inspector"
  delegated_admin_account_id = var.security_account_id
}

module "aws_config" {
  source                    = "../../../modules/aws-config"
  org_name                  = var.org_name
  account_id                = var.security_account_id
  log_archive_bucket_name   = data.terraform_remote_state.log_archive.outputs.log_archive_bucket_name
  kms_key_arn               = module.kms.key_arn
  org_aggregator_account_id = var.security_account_id
}
