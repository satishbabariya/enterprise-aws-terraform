output "kms_key_arn" {
  description = "Shared services KMS key ARN"
  value       = module.workload_baseline.kms_key_arn
}

output "terraform_ci_role_arn" {
  description = "Shared services CI role ARN"
  value       = module.workload_baseline.terraform_ci_role_arn
}
