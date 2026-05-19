data "terraform_remote_state" "log_archive" {
  backend = "s3"
  config = {
    bucket = "${var.org_name}-us-east-1-tfstate"
    key    = "log-archive/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "management" {
  backend = "s3"
  config = {
    bucket = "${var.org_name}-us-east-1-tfstate"
    key    = "management/terraform.tfstate"
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
  source                           = "../../../modules/aws-config"
  org_name                         = var.org_name
  account_id                       = var.security_account_id
  log_archive_bucket_name          = data.terraform_remote_state.log_archive.outputs.log_archive_bucket_name
  kms_key_arn                      = module.kms.key_arn
  org_aggregator_account_id        = var.security_account_id
  conformance_pack_delivery_bucket = data.terraform_remote_state.log_archive.outputs.log_archive_bucket_name
}

# Central AWS Backup vault. Workload accounts tag resources with Backup=true
# to be included in the backup selection.
module "central_backup" {
  source      = "../../../modules/aws-backup"
  org_name    = var.org_name
  kms_key_arn = module.kms.key_arn
}

# Athena + Glue for querying CloudTrail / VPC flow logs in the log archive
module "log_querying" {
  source                  = "../../../modules/log-querying"
  org_name                = var.org_name
  log_archive_bucket_name = data.terraform_remote_state.log_archive.outputs.log_archive_bucket_name
  kms_key_arn             = module.kms.key_arn
}

# Audit Manager: org-wide delegated admin registration
module "audit_manager" {
  source                     = "../../../modules/audit-manager"
  org_name                   = var.org_name
  evidence_bucket_name       = data.terraform_remote_state.log_archive.outputs.log_archive_bucket_name
  kms_key_arn                = module.kms.key_arn
  delegated_admin_account_id = var.security_account_id
}

# GuardDuty auto-remediation: high/critical SNS routing + auto-quarantine for known-bad findings
module "guardduty_auto_remediation" {
  source                   = "../../../modules/guardduty-auto-remediation"
  org_name                 = var.org_name
  critical_alert_topic_arn = data.terraform_remote_state.management.outputs.notification_topic_arns["critical"]
  high_alert_topic_arn     = data.terraform_remote_state.management.outputs.notification_topic_arns["high"]
}
