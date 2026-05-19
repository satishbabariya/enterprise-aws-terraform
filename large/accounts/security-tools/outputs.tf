output "kms_key_arn" {
  description = "Security tools KMS key ARN"
  value       = module.workload_baseline.kms_key_arn
}
