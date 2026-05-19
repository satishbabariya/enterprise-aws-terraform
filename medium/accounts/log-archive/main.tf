module "kms" {
  source      = "../../../modules/kms"
  account_id  = var.log_archive_account_id
  description = "Log archive account KMS key"
  key_alias   = "${var.org_name}-log-archive-general"
}

module "baseline" {
  source     = "../../../modules/account-baseline"
  account_id = var.log_archive_account_id
}

module "log_archive_bucket" {
  source                     = "../../../modules/log-archive-bucket"
  org_name                   = var.org_name
  region                     = var.region
  org_id                     = var.org_id
  management_account_id      = var.management_account_id
  kms_key_arn                = module.kms.key_arn
  object_lock_retention_days = var.object_lock_retention_days

  # Cross-account AuditReader role - assumable by anyone in the security account.
  # SecurityEngineers and Auditors SSO groups (in management) get permission to
  # assume this role via their permission sets to query the centralized logs
  # without needing a per-prefix S3 IAM grant in their own session.
  audit_reader_principal_arns = ["arn:aws:iam::${var.security_account_id}:root"]
  audit_reader_external_id    = var.audit_reader_external_id
}
