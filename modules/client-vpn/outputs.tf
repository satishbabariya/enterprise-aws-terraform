output "endpoint_id" {
  description = "Client VPN endpoint ID"
  value       = aws_ec2_client_vpn_endpoint.this.id
}

output "endpoint_dns_name" {
  description = "DNS name clients connect to"
  value       = aws_ec2_client_vpn_endpoint.this.dns_name
}

output "self_service_portal_url" {
  description = "Self-service portal URL (federated auth only)"
  value       = var.saml_provider_arn != "" ? aws_ec2_client_vpn_endpoint.this.self_service_portal_url : ""
}
