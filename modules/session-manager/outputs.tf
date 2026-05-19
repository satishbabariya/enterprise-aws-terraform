output "instance_profile_name" {
  description = "Attach this instance profile to EC2 instances to enable Session Manager"
  value       = aws_iam_instance_profile.ssm.name
}

output "instance_profile_arn" {
  description = "Instance profile ARN"
  value       = aws_iam_instance_profile.ssm.arn
}

output "instance_role_arn" {
  description = "Instance role ARN (use this if you need to attach additional policies)"
  value       = aws_iam_role.instance.arn
}

output "session_log_group_name" {
  description = "CloudWatch log group receiving session streams"
  value       = aws_cloudwatch_log_group.sessions.name
}
