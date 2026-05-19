output "quarantine_lambda_arn" {
  description = "ARN of the auto-quarantine Lambda"
  value       = aws_lambda_function.quarantine.arn
}

output "high_severity_rule_arn" {
  description = "EventBridge rule ARN for high-severity findings"
  value       = aws_cloudwatch_event_rule.high_severity.arn
}

output "critical_severity_rule_arn" {
  description = "EventBridge rule ARN for critical findings"
  value       = aws_cloudwatch_event_rule.critical_severity.arn
}

output "auto_quarantine_rule_arn" {
  description = "EventBridge rule ARN for auto-quarantine findings"
  value       = aws_cloudwatch_event_rule.auto_quarantine.arn
}
