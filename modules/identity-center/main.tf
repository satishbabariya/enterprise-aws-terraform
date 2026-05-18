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

resource "aws_ssoadmin_account_assignment" "this" {
  for_each = {
    for a in var.account_assignments :
    "${a.account_id}-${a.permission_set_name}-${a.principal_id}" => a
  }

  instance_arn       = var.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.permission_set_name].arn
  principal_id       = each.value.principal_id
  principal_type     = each.value.principal_type
  target_id          = each.value.account_id
  target_type        = "AWS_ACCOUNT"
}
