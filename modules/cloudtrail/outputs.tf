output "trail_arn" {
  description = "CloudTrail trail ARN"
  value       = aws_cloudtrail.org.arn
}

output "trail_name" {
  description = "CloudTrail trail name"
  value       = aws_cloudtrail.org.name
}

output "cloudwatch_log_group_arn" {
  description = "CloudWatch log group receiving trail events (empty if disabled)"
  value       = try(aws_cloudwatch_log_group.trail[0].arn, "")
}

output "cloudwatch_log_group_name" {
  description = "CloudWatch log group name"
  value       = try(aws_cloudwatch_log_group.trail[0].name, "")
}

output "delivery_sns_topic_arn" {
  description = "SNS topic CloudTrail publishes log-file-delivery notifications to (empty if disabled)"
  value       = try(aws_sns_topic.delivery[0].arn, "")
}

output "cis_metric_filter_names" {
  description = "Names of CIS-mapped metric filters"
  value       = [for k in keys(local.cis_metric_filters) : k if local.has_cw_logs]
}

output "cis_alarm_arns" {
  description = "Map of CIS rule key to CloudWatch alarm ARN"
  value       = { for k, v in aws_cloudwatch_metric_alarm.cis : k => v.arn }
}

output "eventbridge_rule_arns" {
  description = "EventBridge rule ARNs - subscribe Lambdas or step functions to these for auto-remediation"
  value = var.enable_eventbridge_remediation ? {
    public_sg_ingress       = aws_cloudwatch_event_rule.public_sg_ingress[0].arn
    iam_access_key_created  = aws_cloudwatch_event_rule.iam_access_key_created[0].arn
    iam_user_created        = aws_cloudwatch_event_rule.iam_user_created[0].arn
    s3_public_access_change = aws_cloudwatch_event_rule.s3_public_access_change[0].arn
  } : {}
}
