# CUR must be created in us-east-1 - that's where the billing endpoint lives.
resource "aws_cur_report_definition" "this" {
  provider = aws.us_east_1

  report_name                = "${var.org_name}-org-cur"
  time_unit                  = "HOURLY"
  format                     = "Parquet"
  compression                = "Parquet"
  additional_schema_elements = ["RESOURCES", "SPLIT_COST_ALLOCATION_DATA"]
  s3_bucket                  = var.cur_bucket_name
  s3_prefix                  = "cur"
  s3_region                  = var.cur_bucket_region
  additional_artifacts       = ["ATHENA"]
  refresh_closed_reports     = true
  report_versioning          = "OVERWRITE_REPORT"
}

resource "aws_ce_anomaly_monitor" "service" {
  name              = "${var.org_name}-service-anomaly-monitor"
  monitor_type      = "DIMENSIONAL"
  monitor_dimension = "SERVICE"
  tags              = var.tags
}

resource "aws_ce_anomaly_subscription" "service" {
  name      = "${var.org_name}-service-anomaly-alerts"
  frequency = "IMMEDIATE"

  monitor_arn_list = [aws_ce_anomaly_monitor.service.arn]

  subscriber {
    type    = "SNS"
    address = var.anomaly_alert_topic_arn
  }

  threshold_expression {
    dimension {
      key           = "ANOMALY_TOTAL_IMPACT_ABSOLUTE"
      values        = ["100"]
      match_options = ["GREATER_THAN_OR_EQUAL"]
    }
  }

  tags = var.tags
}

resource "aws_budgets_budget" "org_monthly" {
  name              = "${var.org_name}-org-monthly-budget"
  budget_type       = "COST"
  limit_amount      = tostring(var.monthly_org_budget_usd)
  limit_unit        = "USD"
  time_unit         = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.budget_notification_emails
    subscriber_sns_topic_arns  = [var.anomaly_alert_topic_arn]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = var.budget_notification_emails
    subscriber_sns_topic_arns  = [var.anomaly_alert_topic_arn]
  }
}
