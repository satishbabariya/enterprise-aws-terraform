output "secrets_kms_key_arn" {
  description = "KMS key ARN to use as kms_key_id on aws_secretsmanager_secret resources"
  value       = module.kms.key_arn
}

output "secrets_kms_key_id" {
  description = "KMS key ID for Secrets Manager"
  value       = module.kms.key_id
}

output "rotation_lambda_role_arn" {
  description = "IAM role ARN to attach to Secrets Manager rotation Lambdas"
  value       = aws_iam_role.rotation_lambda.arn
}
