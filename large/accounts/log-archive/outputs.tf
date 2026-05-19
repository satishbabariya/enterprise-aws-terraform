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
