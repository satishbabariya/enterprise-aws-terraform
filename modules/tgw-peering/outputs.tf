output "attachment_id" {
  description = "Peering attachment ID (use on both sides for route table associations)"
  value       = aws_ec2_transit_gateway_peering_attachment.this.id
}
