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

output "custom_permission_set_arns" {
  description = "Custom persona permission set ARNs"
  value       = module.identity_center.custom_permission_set_arns
}

output "sso_group_ids" {
  description = "SSO group IDs by name - add humans to these groups via your IdP"
  value       = module.identity_center.group_ids
}

output "break_glass_alert_topic_arn" {
  description = "SNS topic that fires when BreakGlassAdmin is assumed"
  value       = aws_sns_topic.break_glass_alerts.arn
}

output "terraform_ci_role_arn" {
  description = "Management Terraform CI role ARN"
  value       = aws_iam_role.terraform_ci.arn
}

output "cloudtrail_trail_arn" {
  description = "Organization CloudTrail ARN"
  value       = module.cloudtrail.trail_arn
}

output "notification_topic_arns" {
  description = "Central SNS topics by severity"
  value       = module.notifications.topic_arns
}

output "central_event_bus_arn" {
  description = "Central EventBridge bus ARN"
  value       = module.notifications.event_bus_arn
}

output "tag_policy_id" {
  description = "Org-wide tag policy ID"
  value       = module.tag_policies.policy_id
}

output "cloudtrail_log_group_name" {
  description = "CloudWatch log group receiving the org trail"
  value       = module.cloudtrail.cloudwatch_log_group_name
}

output "cloudtrail_cis_alarm_arns" {
  description = "Map of CIS rule key to CloudWatch alarm ARN"
  value       = module.cloudtrail.cis_alarm_arns
}

output "cloudtrail_eventbridge_rule_arns" {
  description = "EventBridge rule ARNs for CloudTrail auto-remediation"
  value       = module.cloudtrail.eventbridge_rule_arns
}

output "cloudtrail_lake_arn" {
  description = "CloudTrail Lake Event Data Store ARN (7-year retention)"
  value       = module.cloudtrail_lake.event_data_store_arn
}
