mock_provider "aws" {}

variables {
  name        = "test-fn"
  handler     = "index.handler"
  kms_key_arn = "arn:aws:kms:us-east-1:111111111111:key/abc"
  filename    = "test.zip"
}

run "arm64_default" {
  command = plan

  assert {
    condition     = contains(aws_lambda_function.this.architectures, "arm64")
    error_message = "Default architecture should be arm64"
  }
}

run "xray_tracing_active" {
  command = plan

  assert {
    condition     = aws_lambda_function.this.tracing_config[0].mode == "Active"
    error_message = "X-Ray tracing must be Active"
  }
}

run "log_group_kms_encrypted" {
  command = plan

  assert {
    condition     = aws_cloudwatch_log_group.this.kms_key_id == var.kms_key_arn
    error_message = "Log group must be KMS-encrypted"
  }
}

run "layers_limit_enforced" {
  command = plan

  variables {
    layers = [
      "arn:aws:lambda:us-east-1:111111111111:layer:a:1",
      "arn:aws:lambda:us-east-1:111111111111:layer:b:1",
      "arn:aws:lambda:us-east-1:111111111111:layer:c:1",
      "arn:aws:lambda:us-east-1:111111111111:layer:d:1",
      "arn:aws:lambda:us-east-1:111111111111:layer:e:1",
      "arn:aws:lambda:us-east-1:111111111111:layer:f:1",
    ]
  }

  expect_failures = [var.layers]
}

run "permissions_boundary_applied" {
  command = plan

  variables {
    permissions_boundary_arn = "arn:aws:iam::111111111111:policy/dev-boundary"
  }

  assert {
    condition     = aws_iam_role.this.permissions_boundary == "arn:aws:iam::111111111111:policy/dev-boundary"
    error_message = "Permissions boundary must be applied to execution role"
  }
}

run "function_url_off_by_default" {
  command = plan

  assert {
    condition     = length(aws_lambda_function_url.this) == 0
    error_message = "Function URL must be off by default"
  }
}

run "function_url_authorizes_aws_iam_by_default" {
  command = plan

  variables {
    function_url_enabled = true
  }

  assert {
    condition     = aws_lambda_function_url.this[0].authorization_type == "AWS_IAM"
    error_message = "Function URL must require AWS_IAM auth by default - opt-in to public"
  }
}

run "lambda_insights_layer_attached" {
  command = plan

  variables {
    enable_lambda_insights    = true
    lambda_insights_layer_arn = "arn:aws:lambda:us-east-1:580247275435:layer:LambdaInsightsExtension-Arm64:18"
  }

  assert {
    condition     = contains(aws_lambda_function.this.layers, "arn:aws:lambda:us-east-1:580247275435:layer:LambdaInsightsExtension-Arm64:18")
    error_message = "Insights layer must be attached when enable_lambda_insights = true"
  }
}
