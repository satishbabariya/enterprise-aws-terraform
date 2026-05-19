output "rule_group_id" {
  description = "DNS firewall rule group ID"
  value       = aws_route53_resolver_firewall_rule_group.this.id
}

output "rule_group_arn" {
  description = "DNS firewall rule group ARN"
  value       = aws_route53_resolver_firewall_rule_group.this.arn
}

output "vpc_association_ids" {
  description = "Map of VPC ID to association ID"
  value       = { for k, v in aws_route53_resolver_firewall_rule_group_association.this : k => v.id }
}
