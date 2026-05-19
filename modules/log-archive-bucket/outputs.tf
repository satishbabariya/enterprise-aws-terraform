output "bucket_name" {
  description = "Name of the log archive S3 bucket"
  value       = aws_s3_bucket.logs.bucket
}

output "bucket_arn" {
  description = "ARN of the log archive S3 bucket"
  value       = aws_s3_bucket.logs.arn
}

output "bucket_id" {
  description = "ID of the log archive S3 bucket"
  value       = aws_s3_bucket.logs.id
}

output "audit_reader_role_arn" {
  description = "ARN of the cross-account AuditReader role (empty if not created)"
  value       = try(aws_iam_role.audit_reader[0].arn, "")
}
