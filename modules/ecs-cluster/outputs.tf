output "cluster_arn" {
  description = "ECS cluster ARN"
  value       = aws_ecs_cluster.this.arn
}

output "cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.this.name
}

output "task_execution_role_arn" {
  description = "Default task execution role ARN"
  value       = aws_iam_role.task_execution.arn
}

output "exec_log_group_name" {
  description = "Log group for ECS Exec sessions"
  value       = aws_cloudwatch_log_group.exec.name
}
