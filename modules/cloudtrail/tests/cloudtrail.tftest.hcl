mock_provider "aws" {}

variables {
  org_name                = "testorg"
  log_archive_bucket_name = "testorg-us-east-1-log-archive"
  kms_key_arn             = "arn:aws:kms:us-east-1:111111111111:key/abc123"
}

run "trail_required_attributes" {
  command = plan

  assert {
    condition     = aws_cloudtrail.org.is_organization_trail == true
    error_message = "Trail must be org-wide"
  }

  assert {
    condition     = aws_cloudtrail.org.is_multi_region_trail == true
    error_message = "Trail must be multi-region"
  }

  assert {
    condition     = aws_cloudtrail.org.enable_log_file_validation == true
    error_message = "Log file validation must be enabled"
  }

  assert {
    condition     = aws_cloudtrail.org.include_global_service_events == true
    error_message = "Global service events must be captured"
  }

  assert {
    condition     = aws_cloudtrail.org.kms_key_id == var.kms_key_arn
    error_message = "Trail must use the supplied KMS key"
  }
}

run "both_insight_types_enabled" {
  command = plan

  assert {
    condition     = length(aws_cloudtrail.org.insight_selector) == 2
    error_message = "Both ApiCallRateInsight and ApiErrorRateInsight must be configured"
  }
}

run "cw_logs_created_by_default" {
  command = plan

  assert {
    condition     = length(aws_cloudwatch_log_group.trail) == 1
    error_message = "CW log group must be created when enable_cloudwatch_logs = true (default)"
  }

  assert {
    condition     = aws_cloudwatch_log_group.trail[0].kms_key_id == var.kms_key_arn
    error_message = "Log group must be KMS-encrypted"
  }
}

run "fifteen_cis_metric_filters" {
  command = plan

  variables {
    alarms_sns_topic_arn = "arn:aws:sns:us-east-1:111111111111:test"
  }

  assert {
    condition     = length(aws_cloudwatch_log_metric_filter.cis) == 15
    error_message = "Must create 14 CIS metric filters + 1 Organizations changes filter = 15"
  }

  assert {
    condition     = length(aws_cloudwatch_metric_alarm.cis) == 15
    error_message = "Each metric filter must have a paired alarm when SNS topic is supplied"
  }
}

run "trail_stopped_alarm_present_when_alarms_enabled" {
  command = plan

  variables {
    alarms_sns_topic_arn = "arn:aws:sns:us-east-1:111111111111:test"
  }

  assert {
    condition     = length(aws_cloudwatch_metric_alarm.trail_logging_stopped) == 1
    error_message = "Trail-stopped alarm must be created when alarms_sns_topic_arn is supplied"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.trail_logging_stopped[0].comparison_operator == "LessThanThreshold"
    error_message = "Trail-stopped alarm must fire on log volume dropping below threshold"
  }
}

run "eventbridge_rules_created_by_default" {
  command = plan

  assert {
    condition     = length(aws_cloudwatch_event_rule.public_sg_ingress) == 1
    error_message = "public_sg_ingress rule must exist by default"
  }

  assert {
    condition     = length(aws_cloudwatch_event_rule.iam_user_created) == 1
    error_message = "iam_user_created rule must exist by default"
  }

  assert {
    condition     = length(aws_cloudwatch_event_rule.s3_public_access_change) == 1
    error_message = "s3_public_access_change rule must exist by default"
  }
}

run "log_group_class_iv_accepted" {
  command = plan

  variables {
    cloudwatch_log_group_class = "INFREQUENT_ACCESS"
  }

  assert {
    condition     = aws_cloudwatch_log_group.trail[0].log_group_class == "INFREQUENT_ACCESS"
    error_message = "Log group class must respect var.cloudwatch_log_group_class"
  }
}
