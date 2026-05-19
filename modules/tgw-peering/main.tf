data "aws_caller_identity" "primary" {
  provider = aws.primary
}

locals {
  peer_account_id = var.secondary_account_id != "" ? var.secondary_account_id : data.aws_caller_identity.primary.account_id
}

# Initiated from primary side
resource "aws_ec2_transit_gateway_peering_attachment" "this" {
  provider = aws.primary

  transit_gateway_id      = var.primary_tgw_id
  peer_transit_gateway_id = var.secondary_tgw_id
  peer_account_id         = local.peer_account_id
  peer_region             = var.secondary_region

  tags = merge(var.tags, { Name = var.name })
}

# Accepted on secondary side
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "this" {
  provider = aws.secondary

  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.this.id

  tags = merge(var.tags, { Name = "${var.name}-accepter" })
}
