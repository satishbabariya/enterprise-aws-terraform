mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"*\",\"Resource\":\"*\"}]}"
    }
  }
}

variables {
  account_id  = "111111111111"
  description = "Test key"
  key_alias   = "test-key"
}

run "rotation_enabled_for_symmetric" {
  command = plan

  assert {
    condition     = aws_kms_key.this.enable_key_rotation == true
    error_message = "Symmetric keys must have rotation enabled"
  }
}

run "rotation_off_for_asymmetric" {
  command = plan

  variables {
    customer_master_key_spec = "RSA_2048"
    key_usage                = "SIGN_VERIFY"
  }

  assert {
    condition     = aws_kms_key.this.enable_key_rotation == false
    error_message = "Asymmetric keys cannot have rotation - must be false"
  }
}

run "alias_has_alias_prefix" {
  command = plan

  assert {
    condition     = startswith(aws_kms_alias.this.name, "alias/")
    error_message = "KMS alias name must start with alias/"
  }
}

run "deletion_window_validation" {
  command = plan

  variables {
    deletion_window_in_days = 5
  }

  expect_failures = [var.deletion_window_in_days]
}

run "invalid_key_usage_rejected" {
  command = plan

  variables {
    key_usage = "BOGUS"
  }

  expect_failures = [var.key_usage]
}
