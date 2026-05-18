resource "aws_ec2_transit_gateway" "this" {
  description                     = "${var.org_name} Transit Gateway Hub"
  amazon_side_asn                 = var.amazon_side_asn
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"

  tags = merge(var.tags, { Name = "${var.org_name}-tgw-hub" })
}

resource "aws_ram_resource_share" "tgw" {
  name                      = "${var.org_name}-tgw-share"
  allow_external_principals = false
  tags                      = var.tags
}

resource "aws_ram_resource_association" "tgw" {
  resource_arn       = aws_ec2_transit_gateway.this.arn
  resource_share_arn = aws_ram_resource_share.tgw.arn
}
