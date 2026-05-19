output "fis_role_arn" {
  description = "FIS service role ARN"
  value       = aws_iam_role.fis.arn
}

output "experiment_template_ids" {
  description = "Map of experiment name to FIS template ID"
  value = {
    ec2_stop     = aws_fis_experiment_template.ec2_stop.id
    az_failure   = aws_fis_experiment_template.az_failure.id
    rds_failover = aws_fis_experiment_template.rds_failover.id
  }
}
