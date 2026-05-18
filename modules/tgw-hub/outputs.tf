output "tgw_id" {
  description = "Transit Gateway ID"
  value       = aws_ec2_transit_gateway.this.id
}

output "tgw_arn" {
  description = "Transit Gateway ARN"
  value       = aws_ec2_transit_gateway.this.arn
}

output "ram_share_arn" {
  description = "RAM resource share ARN"
  value       = aws_ram_resource_share.tgw.arn
}

output "default_route_table_id" {
  description = "Default TGW route table ID"
  value       = aws_ec2_transit_gateway.this.association_default_route_table_id
}
