mock_provider "aws" {
  mock_data "aws_partition" {
    defaults = {
      partition = "aws"
    }
  }
  mock_data "aws_region" {
    defaults = {
      region = "us-east-1"
    }
  }
}

run "default_standards_enabled" {
  command = plan

  assert {
    condition     = length(aws_securityhub_standards_subscription.cis) == 1
    error_message = "CIS standard must be enabled by default"
  }

  assert {
    condition     = length(aws_securityhub_standards_subscription.pci) == 1
    error_message = "PCI-DSS standard must be enabled by default"
  }

  assert {
    condition     = length(aws_securityhub_standards_subscription.nist) == 1
    error_message = "NIST standard must be enabled by default"
  }
}

run "finding_aggregator_default_all_regions" {
  command = plan

  assert {
    condition     = aws_securityhub_finding_aggregator.this[0].linking_mode == "ALL_REGIONS"
    error_message = "Default finding aggregator should aggregate ALL_REGIONS"
  }
}

run "finding_aggregator_specific_regions" {
  command = plan

  variables {
    finding_aggregator_regions = ["us-east-1", "us-west-2", "eu-west-1"]
  }

  assert {
    condition     = aws_securityhub_finding_aggregator.this[0].linking_mode == "SPECIFIED_REGIONS"
    error_message = "When specific regions supplied, linking_mode must be SPECIFIED_REGIONS"
  }
}

run "finding_aggregator_disabled" {
  command = plan

  variables {
    finding_aggregator_regions = []
  }

  assert {
    condition     = length(aws_securityhub_finding_aggregator.this) == 0
    error_message = "Empty finding_aggregator_regions must disable the aggregator"
  }
}

run "product_subscriptions_defaults" {
  command = plan

  assert {
    condition     = length(aws_securityhub_product_subscription.this) == 5
    error_message = "Default 5 product subscriptions (guardduty, inspector, macie, config, access_analyzer) must be enabled"
  }
}

run "suppressed_controls" {
  command = plan

  variables {
    suppressed_controls = {
      "Lambda.1" = {
        rule_order      = 1
        disabled_reason = "Public Lambda URLs approved for webhook receiver"
      }
    }
  }

  assert {
    condition     = length(aws_securityhub_automation_rule.suppress) == 1
    error_message = "Automation rule must be created for each suppressed control"
  }

  assert {
    condition     = aws_securityhub_automation_rule.suppress["Lambda.1"].is_terminal == true
    error_message = "Suppression rules must be terminal"
  }
}
