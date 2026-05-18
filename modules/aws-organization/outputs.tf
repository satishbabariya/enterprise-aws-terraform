output "organization_id" {
  description = "AWS Organizations organization ID"
  value       = aws_organizations_organization.this.id
}

output "organization_arn" {
  description = "AWS Organizations organization ARN"
  value       = aws_organizations_organization.this.arn
}

output "master_account_id" {
  description = "Management account ID"
  value       = aws_organizations_organization.this.master_account_id
}

output "root_id" {
  description = "Organization root ID"
  value       = aws_organizations_organization.this.roots[0].id
}

output "organizational_unit_ids" {
  description = "Map of OU key to OU ID"
  value       = { for k, v in aws_organizations_organizational_unit.this : k => v.id }
}

output "organizational_unit_arns" {
  description = "Map of OU key to OU ARN"
  value       = { for k, v in aws_organizations_organizational_unit.this : k => v.arn }
}
