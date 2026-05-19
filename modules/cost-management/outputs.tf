output "cur_report_name" {
  description = "Cost & Usage Report name"
  value       = aws_cur_report_definition.this.report_name
}

output "anomaly_monitor_arn" {
  description = "Cost Anomaly Detection monitor ARN"
  value       = aws_ce_anomaly_monitor.service.arn
}

output "org_budget_id" {
  description = "Org-wide monthly budget ID"
  value       = aws_budgets_budget.org_monthly.id
}
