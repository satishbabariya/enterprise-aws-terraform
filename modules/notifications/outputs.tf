output "topic_arns" {
  description = "Map of severity to SNS topic ARN"
  value       = { for k, v in aws_sns_topic.by_severity : k => v.arn }
}

output "topic_names" {
  description = "Map of severity to SNS topic name"
  value       = { for k, v in aws_sns_topic.by_severity : k => v.name }
}

output "event_bus_arn" {
  description = "Central EventBridge bus ARN"
  value       = aws_cloudwatch_event_bus.central.arn
}

output "event_bus_name" {
  description = "Central EventBridge bus name"
  value       = aws_cloudwatch_event_bus.central.name
}

output "chatbot_role_arn" {
  description = "Chatbot IAM role ARN (use in aws chatbot create-slack-channel-configuration)"
  value       = try(aws_iam_role.chatbot[0].arn, "")
}
