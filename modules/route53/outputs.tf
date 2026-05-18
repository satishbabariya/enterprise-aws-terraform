output "zone_id" {
  description = "Route53 private hosted zone ID"
  value       = aws_route53_zone.private.zone_id
}

output "zone_arn" {
  description = "Route53 private hosted zone ARN"
  value       = aws_route53_zone.private.arn
}

output "name_servers" {
  description = "Route53 name servers"
  value       = aws_route53_zone.private.name_servers
}
