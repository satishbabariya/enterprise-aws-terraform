output "global_cluster_id" {
  description = "Global cluster ID"
  value       = aws_rds_global_cluster.this.id
}

output "primary_endpoint" {
  description = "Primary writer endpoint"
  value       = aws_rds_cluster.primary.endpoint
}

output "primary_reader_endpoint" {
  description = "Primary reader (load-balanced) endpoint"
  value       = aws_rds_cluster.primary.reader_endpoint
}

output "secondary_reader_endpoint" {
  description = "Secondary region reader endpoint - use for read traffic close to secondary-region clients"
  value       = aws_rds_cluster.secondary.reader_endpoint
}

output "primary_secret_arn" {
  description = "Secrets Manager ARN for the master password"
  value       = aws_rds_cluster.primary.master_user_secret[0].secret_arn
}
