output "policy_ids" {
  description = "Map of SCP name to policy ID"
  value = {
    deny_root_actions        = aws_organizations_policy.deny_root_actions.id
    deny_leave_org           = aws_organizations_policy.deny_leave_org.id
    deny_regions             = aws_organizations_policy.deny_regions.id
    require_imdsv2           = aws_organizations_policy.require_imdsv2.id
    deny_s3_public           = aws_organizations_policy.deny_s3_public.id
    deny_iam_user_creation   = aws_organizations_policy.deny_iam_user_creation.id
    deny_unencrypted_storage = aws_organizations_policy.deny_unencrypted_storage.id
    deny_vpc_changes         = aws_organizations_policy.deny_vpc_changes.id
  }
}
