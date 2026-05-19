output "firewall_arn" {
  description = "Network Firewall ARN"
  value       = aws_networkfirewall_firewall.this.arn
}

output "firewall_id" {
  description = "Network Firewall ID"
  value       = aws_networkfirewall_firewall.this.id
}

output "firewall_endpoint_ids" {
  description = "Map of subnet ID to firewall endpoint ID - use in route tables"
  value = {
    for ss in tolist(aws_networkfirewall_firewall.this.firewall_status[0].sync_states) :
    ss.availability_zone => ss.attachment[0].endpoint_id
  }
}

output "policy_arn" {
  description = "Firewall policy ARN"
  value       = aws_networkfirewall_firewall_policy.this.arn
}
