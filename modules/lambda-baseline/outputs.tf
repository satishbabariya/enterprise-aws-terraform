output "function_arn" {
  description = "Lambda function ARN"
  value       = aws_lambda_function.this.arn
}

output "function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.this.function_name
}

output "execution_role_arn" {
  description = "Execution role ARN - attach additional policies via aws_iam_role_policy_attachment from the caller"
  value       = aws_iam_role.this.arn
}

output "execution_role_name" {
  description = "Execution role name"
  value       = aws_iam_role.this.name
}

output "log_group_name" {
  description = "Lambda CloudWatch log group name"
  value       = aws_cloudwatch_log_group.this.name
}

output "function_url" {
  description = "Function URL (empty if disabled). Public HTTPS endpoint - signed requests required if authorization_type = AWS_IAM."
  value       = try(aws_lambda_function_url.this[0].function_url, "")
}

output "version" {
  description = "Latest published version (only meaningful if publish_version = true)"
  value       = aws_lambda_function.this.version
}
