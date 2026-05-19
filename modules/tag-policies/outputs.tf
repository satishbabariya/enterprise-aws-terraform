output "policy_id" {
  description = "Tag policy ID - attach this to OUs via aws_organizations_policy_attachment"
  value       = aws_organizations_policy.required_tags.id
}

output "policy_arn" {
  description = "Tag policy ARN"
  value       = aws_organizations_policy.required_tags.arn
}
