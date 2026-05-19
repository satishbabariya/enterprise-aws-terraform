output "organization_id" {
  description = "AWS Organizations organization ID"
  value       = module.organization.organization_id
}

output "root_id" {
  description = "Organization root ID"
  value       = module.organization.root_id
}

output "ou_ids" {
  description = "Map of OU key to OU ID"
  value       = module.organization.organizational_unit_ids
}

output "kms_key_arn" {
  description = "Management KMS key ARN"
  value       = module.kms.key_arn
}

output "permission_set_arns" {
  description = "Identity Center permission set ARNs"
  value       = module.identity_center.permission_set_arns
}

output "terraform_ci_role_arn" {
  description = "Management Terraform CI role ARN"
  value       = aws_iam_role.terraform_ci.arn
}

output "cloudtrail_trail_arn" {
  description = "Organization CloudTrail ARN"
  value       = module.cloudtrail.trail_arn
}
