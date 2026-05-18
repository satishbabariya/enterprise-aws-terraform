output "permission_set_arns" {
  description = "Map of permission set name to ARN"
  value       = { for k, v in aws_ssoadmin_permission_set.this : k => v.arn }
}
