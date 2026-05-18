output "s3_public_access_block_id" {
  description = "ID of the S3 account public access block"
  value       = aws_s3_account_public_access_block.this.id
}
