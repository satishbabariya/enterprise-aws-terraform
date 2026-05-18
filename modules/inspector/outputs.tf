output "delegated_admin_account_id" {
  description = "Inspector delegated admin account ID"
  value       = aws_inspector2_delegated_admin_account.this.account_id
}
