resource "aws_ec2_client_vpn_endpoint" "this" {
  description            = "${var.org_name} workforce VPN"
  server_certificate_arn = var.server_certificate_arn
  client_cidr_block      = var.client_cidr_block
  split_tunnel           = var.split_tunnel
  session_timeout_hours  = var.session_timeout_hours
  vpc_id                 = var.vpc_id
  self_service_portal    = var.saml_provider_arn != "" ? "enabled" : "disabled"
  transport_protocol     = "udp"
  vpn_port               = 443

  dynamic "authentication_options" {
    for_each = var.saml_provider_arn != "" ? [1] : []
    content {
      type                           = "federated-authentication"
      saml_provider_arn              = var.saml_provider_arn
      self_service_saml_provider_arn = var.self_service_saml_provider_arn != "" ? var.self_service_saml_provider_arn : var.saml_provider_arn
    }
  }

  dynamic "authentication_options" {
    for_each = var.mutual_auth_root_ca_arn != "" ? [1] : []
    content {
      type                       = "certificate-authentication"
      root_certificate_chain_arn = var.mutual_auth_root_ca_arn
    }
  }

  connection_log_options {
    enabled              = true
    cloudwatch_log_group = var.log_group_name
  }

  client_login_banner_options {
    enabled     = true
    banner_text = "${var.org_name} corporate VPN. Authorized access only. All traffic is logged."
  }

  tags = merge(var.tags, { Name = "${var.org_name}-client-vpn" })
}

resource "aws_ec2_client_vpn_network_association" "this" {
  for_each = toset(var.subnet_ids)

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  subnet_id              = each.value
}

# Authorization rules - one per group, or one wildcard if no groups specified
resource "aws_ec2_client_vpn_authorization_rule" "all_users" {
  for_each = length(var.authorize_groups) == 0 ? toset(var.allowed_routes) : []

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  target_network_cidr    = each.value
  authorize_all_groups   = true
  description            = "Allow all authenticated users to ${each.value}"
}

resource "aws_ec2_client_vpn_authorization_rule" "by_group" {
  for_each = {
    for combo in flatten([
      for route in var.allowed_routes : [
        for group in var.authorize_groups : {
          key   = "${route}-${group}"
          route = route
          group = group
        }
      ]
    ]) : combo.key => combo
  }

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  target_network_cidr    = each.value.route
  access_group_id        = each.value.group
  description            = "Allow group ${each.value.group} to ${each.value.route}"
}

resource "aws_ec2_client_vpn_route" "routes" {
  for_each = {
    for combo in flatten([
      for subnet in var.subnet_ids : [
        for route in var.allowed_routes : {
          key             = "${subnet}-${route}"
          subnet          = subnet
          destination     = route
        }
      ]
    ]) : combo.key => combo
  }

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  destination_cidr_block = each.value.destination
  target_vpc_subnet_id   = each.value.subnet

  depends_on = [aws_ec2_client_vpn_network_association.this]
}
