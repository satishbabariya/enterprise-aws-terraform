output "alb_dns_name" {
  description = "ALB DNS name - create a Route53 alias record pointing var.domain_name at this"
  value       = aws_lb.this.dns_name
}

output "alb_zone_id" {
  description = "ALB hosted zone ID - use as zone_id in the Route53 alias record"
  value       = aws_lb.this.zone_id
}

output "database_endpoint" {
  description = "Aurora writer endpoint (used by the app via DB_HOST env)"
  value       = module.database.cluster_endpoint
}

output "database_secret_arn" {
  description = "Secrets Manager ARN holding master credentials. Aurora rotates this automatically."
  value       = module.database.secret_arn
  sensitive   = true
}

output "ecs_cluster_arn" {
  description = "ECS cluster ARN"
  value       = module.ecs.cluster_arn
}

output "ecs_service_name" {
  description = "ECS service name (useful for aws ecs update-service deployments)"
  value       = aws_ecs_service.this.name
}

output "task_iam_role_arn" {
  description = "Task IAM role - attach additional policies for AWS services the app needs"
  value       = aws_iam_role.task.arn
}

output "log_group_name" {
  description = "CloudWatch log group for the app container"
  value       = aws_cloudwatch_log_group.app.name
}

output "waf_web_acl_arn" {
  description = "WAF ACL associated with the ALB"
  value       = module.waf.web_acl_arn
}
