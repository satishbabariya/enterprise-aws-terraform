mock_provider "aws" {}

variables {
  delegated_admin_account_id = "222222222222"
}

run "detector_enabled" {
  command = plan

  assert {
    condition     = aws_guardduty_detector.this.enable == true
    error_message = "Detector must be enabled"
  }

  assert {
    condition     = contains(["FIFTEEN_MINUTES", "ONE_HOUR", "SIX_HOURS"], aws_guardduty_detector.this.finding_publishing_frequency)
    error_message = "Publishing frequency must be a valid value"
  }
}

run "all_core_features_enabled" {
  command = plan

  assert {
    condition     = aws_guardduty_detector_feature.s3_logs.status == "ENABLED"
    error_message = "S3 protection must be enabled"
  }
  assert {
    condition     = aws_guardduty_detector_feature.ebs_malware_protection.status == "ENABLED"
    error_message = "EBS malware protection must be enabled"
  }
  assert {
    condition     = aws_guardduty_detector_feature.rds_login_events.status == "ENABLED"
    error_message = "RDS login events must be enabled"
  }
  assert {
    condition     = aws_guardduty_detector_feature.lambda_network_logs.status == "ENABLED"
    error_message = "Lambda network logs must be enabled"
  }
}

run "runtime_monitoring_default_enabled" {
  command = plan

  assert {
    condition     = length(aws_guardduty_detector_feature.runtime_monitoring) == 1
    error_message = "Runtime Monitoring must be enabled by default"
  }
}

run "runtime_monitoring_and_eks_legacy_mutually_exclusive" {
  command = plan

  variables {
    enable_runtime_monitoring     = true
    enable_eks_runtime_monitoring = true
  }

  expect_failures = [
    var.enable_eks_runtime_monitoring,
  ]
}

run "org_admin_delegated" {
  command = plan

  assert {
    condition     = aws_guardduty_organization_admin_account.this.admin_account_id == var.delegated_admin_account_id
    error_message = "Delegated admin account must match input"
  }
}

run "org_configuration_features" {
  command = plan

  # Org-wide feature config: 5 base features + 1 runtime monitoring = 6
  # (using count, so we count via the resources)
  assert {
    condition     = length(aws_guardduty_organization_configuration_feature.runtime_monitoring) == 1
    error_message = "Runtime monitoring org-wide config must exist by default"
  }
}
