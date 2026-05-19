resource "aws_organizations_account" "this" {
  for_each = var.accounts

  name                       = each.key
  email                      = each.value.email
  parent_id                  = each.value.ou_id
  role_name                  = each.value.role_name
  iam_user_access_to_billing = each.value.iam_user_access
  close_on_deletion          = each.value.close_on_destroy

  tags = var.tags

  # Account creation cannot be reverted by tainting - protect from accidental destroy.
  lifecycle {
    ignore_changes = [role_name]
  }
}
