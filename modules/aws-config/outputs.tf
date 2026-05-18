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
