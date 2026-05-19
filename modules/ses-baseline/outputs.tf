output "identity_arn" {
  description = "SES email identity ARN - use as source_arn in apps"
  value       = aws_sesv2_email_identity.this.arn
}

output "configuration_set_arn" {
  description = "Configuration set ARN"
  value       = aws_sesv2_configuration_set.this.arn
}

output "dkim_tokens" {
  description = "DKIM tokens (used in CNAME records if Route53 zone wasn't supplied)"
  value       = aws_sesv2_email_identity.this.dkim_signing_attributes[0].tokens
}
