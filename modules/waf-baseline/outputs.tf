output "web_acl_arn" {
  description = "Web ACL ARN - associate to ALB/API Gateway/CloudFront via aws_wafv2_web_acl_association"
  value       = aws_wafv2_web_acl.this.arn
}

output "web_acl_id" {
  description = "Web ACL ID"
  value       = aws_wafv2_web_acl.this.id
}

output "shield_protection_ids" {
  description = "Map of resource ARN to Shield protection ID (empty if Shield Advanced disabled)"
  value       = { for k, v in aws_shield_protection.this : k => v.id }
}
