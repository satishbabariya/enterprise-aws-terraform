# Audit Manager has limited Terraform resource coverage as of provider 5.x.
# This module provisions what IS supported: the org-wide configuration anchor.
# Assessment creation must be done via console / API after this is applied -
# see docs/audit-manager.md for the runbook.

resource "aws_auditmanager_account_registration" "this" {
  delegated_admin_account = var.delegated_admin_account_id
  deregister_on_destroy   = false
}

resource "aws_auditmanager_organization_admin_account_registration" "this" {
  admin_account_id = var.delegated_admin_account_id
  depends_on       = [aws_auditmanager_account_registration.this]
}
