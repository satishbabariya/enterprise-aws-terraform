resource "aws_s3_account_public_access_block" "this" {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_ebs_encryption_by_default" "this" {
  enabled = true
}

resource "aws_ec2_instance_metadata_defaults" "this" {
  http_tokens                 = "required"
  http_put_response_hop_limit = 1
  instance_metadata_tags      = "enabled"
}

resource "aws_iam_account_password_policy" "this" {
  minimum_password_length        = var.iam_account_password_policy.minimum_password_length
  require_lowercase_characters   = var.iam_account_password_policy.require_lowercase_characters
  require_uppercase_characters   = var.iam_account_password_policy.require_uppercase_characters
  require_numbers                = var.iam_account_password_policy.require_numbers
  require_symbols                = var.iam_account_password_policy.require_symbols
  allow_users_to_change_password = var.iam_account_password_policy.allow_users_to_change_password
  max_password_age               = var.iam_account_password_policy.max_password_age
  password_reuse_prevention      = var.iam_account_password_policy.password_reuse_prevention
  hard_expiry                    = var.iam_account_password_policy.hard_expiry
}

resource "aws_budgets_budget" "monthly" {
  name         = "monthly-budget-alert"
  budget_type  = "COST"
  limit_amount = tostring(var.monthly_budget_amount_usd)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.budget_notification_emails
  }
}
