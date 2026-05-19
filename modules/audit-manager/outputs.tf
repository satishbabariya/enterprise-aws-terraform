output "delegated_admin_account_id" {
  description = "Audit Manager delegated admin account"
  value       = aws_auditmanager_organization_admin_account_registration.this.admin_account_id
}
