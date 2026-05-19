output "kms_key_arn" {
  description = "ARN of the general-purpose KMS key"
  value       = module.kms.key_arn
}

output "kms_key_id" {
  description = "ID of the general-purpose KMS key"
  value       = module.kms.key_id
}

output "state_bucket_name" {
  description = "Name of the per-account state bucket"
  value       = module.state_backend.bucket_name
}

output "terraform_ci_role_arn" {
  description = "ARN of the CI role assumed by GitHub Actions"
  value       = aws_iam_role.terraform_ci.arn
}

output "secrets_kms_key_arn" {
  description = "KMS key for Secrets Manager secrets in this account"
  value       = module.secrets.secrets_kms_key_arn
}

output "secrets_rotation_role_arn" {
  description = "IAM role to attach to Secrets Manager rotation Lambdas"
  value       = module.secrets.rotation_lambda_role_arn
}
