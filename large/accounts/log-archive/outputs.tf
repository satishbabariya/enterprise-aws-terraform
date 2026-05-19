output "log_archive_bucket_name" {
  description = "Centralized log archive S3 bucket name"
  value       = module.log_archive_bucket.bucket_name
}

output "log_archive_bucket_arn" {
  description = "Centralized log archive S3 bucket ARN"
  value       = module.log_archive_bucket.bucket_arn
}

output "kms_key_arn" {
  description = "Log archive account KMS key ARN"
  value       = module.kms.key_arn
}

output "audit_reader_role_arn" {
  description = "AuditReader role ARN - cross-account read access to centralized logs. Grant assume-role permission in security account via SSO permission sets."
  value       = module.log_archive_bucket.audit_reader_role_arn
}
