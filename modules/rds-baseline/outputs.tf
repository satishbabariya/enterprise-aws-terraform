output "endpoint" {
  description = "DB endpoint hostname"
  value       = aws_db_instance.this.endpoint
}

output "port" {
  description = "DB port"
  value       = aws_db_instance.this.port
}

output "security_group_id" {
  description = "Security group attached to the DB - reference from client SGs"
  value       = aws_security_group.this.id
}

output "secret_arn" {
  description = "ARN of the Secrets Manager secret holding the master password"
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}

output "instance_arn" {
  description = "DB instance ARN"
  value       = aws_db_instance.this.arn
}
