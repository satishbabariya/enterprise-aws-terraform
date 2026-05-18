output "trail_arn" {
  description = "CloudTrail trail ARN"
  value       = aws_cloudtrail.org.arn
}

output "trail_name" {
  description = "CloudTrail trail name"
  value       = aws_cloudtrail.org.name
}
