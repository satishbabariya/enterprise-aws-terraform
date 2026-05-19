output "vpc_id" {
  description = "Network VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Network VPC private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "tgw_id" {
  description = "Transit Gateway ID"
  value       = module.tgw.tgw_id
}

output "tgw_ram_share_arn" {
  description = "RAM share ARN for TGW cross-account access"
  value       = module.tgw.ram_share_arn
}

output "private_zone_id" {
  description = "Route53 private hosted zone ID"
  value       = module.private_zone.zone_id
}
