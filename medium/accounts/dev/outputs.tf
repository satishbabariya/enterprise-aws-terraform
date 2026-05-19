output "vpc_id" {
  description = "Workload VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Workload VPC private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "kms_key_arn" {
  description = "Workload KMS key ARN"
  value       = module.workload_baseline.kms_key_arn
}

output "terraform_ci_role_arn" {
  description = "Workload Terraform CI role ARN"
  value       = module.workload_baseline.terraform_ci_role_arn
}
