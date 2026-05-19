output "guardduty_detector_id" {
  description = "GuardDuty detector ID"
  value       = module.guardduty.detector_id
}

output "security_hub_arn" {
  description = "Security Hub account resource ID"
  value       = module.security_hub.hub_arn
}

output "analyzer_arn" {
  description = "IAM Access Analyzer ARN"
  value       = module.access_analyzer.analyzer_arn
}

output "central_backup_vault_arn" {
  description = "Central AWS Backup vault ARN"
  value       = module.central_backup.vault_arn
}

output "conformance_pack_arns" {
  description = "Conformance pack ARNs (CIS, PCI-DSS, HIPAA, NIST)"
  value       = module.aws_config.conformance_pack_arns
}

output "athena_workgroup_name" {
  description = "Athena workgroup for querying centralized logs"
  value       = module.log_querying.workgroup_name
}

output "glue_logs_database" {
  description = "Glue database holding CloudTrail / VPC flow log tables"
  value       = module.log_querying.glue_database_name
}

output "guardduty_quarantine_lambda_arn" {
  description = "Lambda that auto-quarantines compromised EC2 instances on specific findings"
  value       = module.guardduty_auto_remediation.quarantine_lambda_arn
}
