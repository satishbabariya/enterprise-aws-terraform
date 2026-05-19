output "workgroup_name" {
  description = "Athena workgroup name"
  value       = aws_athena_workgroup.logs.name
}

output "workgroup_arn" {
  description = "Athena workgroup ARN"
  value       = aws_athena_workgroup.logs.arn
}

output "glue_database_name" {
  description = "Glue catalog database name"
  value       = aws_glue_catalog_database.logs.name
}

output "results_bucket_name" {
  description = "Bucket where Athena query results land"
  value       = local.athena_results_bucket
}
