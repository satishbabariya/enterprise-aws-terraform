output "vpc_id" {
  description = "Data platform VPC ID"
  value       = module.vpc.vpc_id
}

output "kms_key_arn" {
  description = "Data platform KMS key ARN"
  value       = module.workload_baseline.kms_key_arn
}
