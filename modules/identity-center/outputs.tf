output "permission_set_arns" {
  description = "Map of managed-policy-backed permission set name to ARN"
  value       = { for k, v in aws_ssoadmin_permission_set.this : k => v.arn }
}

output "custom_permission_set_arns" {
  description = "Map of custom (inline policy) permission set name to ARN"
  value       = { for k, v in aws_ssoadmin_permission_set.custom : k => v.arn }
}

output "group_ids" {
  description = "Map of group name to identity store group ID"
  value       = { for k, v in aws_identitystore_group.this : k => v.group_id }
}
