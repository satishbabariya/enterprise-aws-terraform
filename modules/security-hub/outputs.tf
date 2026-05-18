output "hub_arn" {
  description = "Security Hub account resource ID"
  value       = aws_securityhub_account.this.id
}
