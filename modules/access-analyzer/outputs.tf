output "analyzer_arn" {
  description = "IAM Access Analyzer ARN"
  value       = aws_accessanalyzer_analyzer.this.arn
}

output "analyzer_name" {
  description = "IAM Access Analyzer name"
  value       = aws_accessanalyzer_analyzer.this.analyzer_name
}
