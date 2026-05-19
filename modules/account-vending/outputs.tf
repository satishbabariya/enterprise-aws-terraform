output "account_ids" {
  description = "Map of account name to 12-digit account ID"
  value       = { for k, v in aws_organizations_account.this : k => v.id }
}

output "account_arns" {
  description = "Map of account name to account ARN"
  value       = { for k, v in aws_organizations_account.this : k => v.arn }
}
