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
