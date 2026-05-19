resource "aws_identitystore_group" "this" {
  for_each = var.groups

  identity_store_id = var.identity_store_id
  display_name      = each.key
  description       = each.value
}

resource "aws_ssoadmin_permission_set" "this" {
  for_each = var.permission_sets

  name             = each.key
  description      = each.value.description
  instance_arn     = var.sso_instance_arn
  session_duration = each.value.session_duration

  tags = var.tags
}

resource "aws_ssoadmin_managed_policy_attachment" "this" {
  for_each = {
    for combo in flatten([
      for ps_name, ps in var.permission_sets : [
        for arn in ps.managed_policy_arns : {
          key                = "${ps_name}--${arn}"
          ps_name            = ps_name
          managed_policy_arn = arn
        }
      ]
    ]) : combo.key => combo
  }

  instance_arn       = var.sso_instance_arn
  managed_policy_arn = each.value.managed_policy_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.ps_name].arn
}

resource "aws_ssoadmin_permission_set" "custom" {
  for_each = var.custom_permission_sets

  name             = each.key
  description      = each.value.description
  instance_arn     = var.sso_instance_arn
  session_duration = each.value.session_duration

  tags = var.tags
}

resource "aws_ssoadmin_managed_policy_attachment" "custom" {
  for_each = {
    for combo in flatten([
      for ps_name, ps in var.custom_permission_sets : [
        for arn in ps.managed_policy_arns : {
          key                = "${ps_name}--${arn}"
          ps_name            = ps_name
          managed_policy_arn = arn
        }
      ]
    ]) : combo.key => combo
  }

  instance_arn       = var.sso_instance_arn
  managed_policy_arn = each.value.managed_policy_arn
  permission_set_arn = aws_ssoadmin_permission_set.custom[each.value.ps_name].arn
}

resource "aws_ssoadmin_permission_set_inline_policy" "custom" {
  for_each = {
    for k, v in var.custom_permission_sets : k => v.inline_policy_json
    if v.inline_policy_json != ""
  }

  instance_arn       = var.sso_instance_arn
  inline_policy      = each.value
  permission_set_arn = aws_ssoadmin_permission_set.custom[each.key].arn
}

locals {
  # Merged map of all permission set ARNs for assignment lookup
  all_permission_set_arns = merge(
    { for k, v in aws_ssoadmin_permission_set.this : k => v.arn },
    { for k, v in aws_ssoadmin_permission_set.custom : k => v.arn }
  )

  # Resolve principal_id: if principal_type is GROUP and the value matches a group key,
  # rewrite to the created group's ID. Otherwise pass through (allows direct user IDs).
  resolved_assignments = [
    for a in var.account_assignments : {
      account_id          = a.account_id
      permission_set_name = a.permission_set_name
      principal_type      = a.principal_type
      principal_id = (
        a.principal_type == "GROUP" && contains(keys(aws_identitystore_group.this), a.principal_id)
        ? aws_identitystore_group.this[a.principal_id].group_id
        : a.principal_id
      )
    }
  ]
}

resource "aws_ssoadmin_account_assignment" "this" {
  for_each = {
    for a in local.resolved_assignments :
    "${a.account_id}-${a.permission_set_name}-${a.principal_id}" => a
  }

  instance_arn       = var.sso_instance_arn
  permission_set_arn = local.all_permission_set_arns[each.value.permission_set_name]
  principal_id       = each.value.principal_id
  principal_type     = each.value.principal_type
  target_id          = each.value.account_id
  target_type        = "AWS_ACCOUNT"
}
