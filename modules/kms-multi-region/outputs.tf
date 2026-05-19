output "primary_key_arn" {
  description = "Primary KMS key ARN (use in primary region resources)"
  value       = aws_kms_key.primary.arn
}

output "primary_key_id" {
  description = "Primary KMS key ID"
  value       = aws_kms_key.primary.key_id
}

output "secondary_key_arn" {
  description = "Replica KMS key ARN (use in secondary region resources, e.g., CRR destination encryption)"
  value       = aws_kms_replica_key.secondary.arn
}

output "secondary_key_id" {
  description = "Replica KMS key ID"
  value       = aws_kms_replica_key.secondary.key_id
}

output "alias_name" {
  description = "Alias (same in both regions)"
  value       = aws_kms_alias.primary.name
}
