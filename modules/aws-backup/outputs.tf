output "vault_arn" {
  description = "Backup vault ARN"
  value       = aws_backup_vault.this.arn
}

output "vault_name" {
  description = "Backup vault name"
  value       = aws_backup_vault.this.name
}

output "plan_arn" {
  description = "Backup plan ARN"
  value       = aws_backup_plan.this.arn
}

output "backup_role_arn" {
  description = "IAM role used by AWS Backup"
  value       = aws_iam_role.backup.arn
}
