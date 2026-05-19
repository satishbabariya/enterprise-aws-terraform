output "hub_arn" {
  description = "Security Hub account resource ID"
  value       = aws_securityhub_account.this.id
}

output "finding_aggregator_arn" {
  description = "Finding aggregator ARN (empty if disabled). The resource id IS the ARN in the AWS provider."
  value       = try(aws_securityhub_finding_aggregator.this[0].id, "")
}

output "product_subscription_arns" {
  description = "Map of product name to subscription ARN"
  value       = { for k, v in aws_securityhub_product_subscription.this : k => v.arn }
}
