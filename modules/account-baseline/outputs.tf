output "s3_public_access_block_id" {
  description = "ID of the S3 account public access block"
  value       = aws_s3_account_public_access_block.this.id
}

output "baselined_account_id" {
  description = "Echoes back the account_id input. Use to assert that callers ran this module against the account they expected (catches misconfigured assume_role)."
  value       = var.account_id
}
