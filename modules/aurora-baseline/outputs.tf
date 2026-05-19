output "cluster_endpoint" {
  description = "Writer endpoint"
  value       = aws_rds_cluster.this.endpoint
}

output "reader_endpoint" {
  description = "Reader (load-balanced) endpoint"
  value       = aws_rds_cluster.this.reader_endpoint
}

output "port" {
  description = "DB port"
  value       = aws_rds_cluster.this.port
}

output "security_group_id" {
  description = "Cluster security group ID"
  value       = aws_security_group.this.id
}

output "secret_arn" {
  description = "Secrets Manager secret ARN for master credentials"
  value       = aws_rds_cluster.this.master_user_secret[0].secret_arn
}

output "cluster_arn" {
  description = "Cluster ARN"
  value       = aws_rds_cluster.this.arn
}
