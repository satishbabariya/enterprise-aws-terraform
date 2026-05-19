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
