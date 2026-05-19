resource "aws_cognito_user_pool" "this" {
  name              = var.name
  mfa_configuration = var.mfa_configuration

  deletion_protection = var.deletion_protection

  password_policy {
    minimum_length                   = var.password_minimum_length
    require_lowercase                = true
    require_uppercase                = true
    require_numbers                  = true
    require_symbols                  = true
    temporary_password_validity_days = 1
  }

  software_token_mfa_configuration {
    enabled = var.mfa_configuration != "OFF"
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  auto_verified_attributes = ["email"]

  username_configuration {
    case_sensitive = false
  }

  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  user_pool_add_ons {
    advanced_security_mode = var.advanced_security_mode
  }

  schema {
    name                     = "email"
    attribute_data_type      = "String"
    required                 = true
    mutable                  = true
    developer_only_attribute = false

    string_attribute_constraints {
      min_length = 5
      max_length = 256
    }
  }

  dynamic "email_configuration" {
    for_each = var.ses_source_arn != "" ? [1] : []
    content {
      email_sending_account = "DEVELOPER"
      source_arn            = var.ses_source_arn
    }
  }

  tags = var.tags
}

resource "aws_cognito_user_pool_client" "this" {
  name         = "${var.name}-app-client"
  user_pool_id = aws_cognito_user_pool.this.id

  generate_secret = true

  refresh_token_validity = 30
  access_token_validity  = 1
  id_token_validity      = 1
  token_validity_units {
    refresh_token = "days"
    access_token  = "hours"
    id_token      = "hours"
  }

  callback_urls                        = var.callback_urls
  logout_urls                          = var.logout_urls
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_flows_user_pool_client = length(var.callback_urls) > 0
  allowed_oauth_scopes                 = ["openid", "email", "profile"]
  supported_identity_providers         = ["COGNITO"]

  prevent_user_existence_errors = "ENABLED"

  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
  ]
}
