output "recorder_id" {
  description = "Config recorder ID"
  value       = aws_config_configuration_recorder.this.id
}

output "aggregator_arn" {
  description = "Config aggregator ARN"
  value       = aws_config_configuration_aggregator.org.arn
}

output "delivery_channel_id" {
  description = "Config delivery channel ID"
  value       = aws_config_delivery_channel.this.id
}

output "conformance_pack_arns" {
  description = "Map of conformance pack key to ARN"
  value       = { for k, v in aws_config_conformance_pack.this : k => v.arn }
}

output "sns_topic_arn" {
  description = "Config SNS notification topic ARN (empty if not created)"
  value       = try(aws_sns_topic.config[0].arn, "")
}

output "managed_rule_arns" {
  description = "Map of managed Config rule name to ARN"
  value       = { for k, v in aws_config_config_rule.managed : k => v.arn }
}
