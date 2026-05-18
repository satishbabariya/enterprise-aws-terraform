variable "account_id" {
  description = "AWS account ID of the account being baselined."
  type        = string
  validation {
    condition     = can(regex("^[0-9]{12}$", var.account_id))
    error_message = "Must be a 12-digit AWS account ID."
  }
}

variable "iam_account_password_policy" {
  description = "IAM account password policy settings."
  type = object({
    minimum_password_length        = number
    require_lowercase_characters   = bool
    require_uppercase_characters   = bool
    require_numbers                = bool
    require_symbols                = bool
    allow_users_to_change_password = bool
    max_password_age               = number
    password_reuse_prevention      = number
    hard_expiry                    = bool
  })
  default = {
    minimum_password_length        = 14
    require_lowercase_characters   = true
    require_uppercase_characters   = true
    require_numbers                = true
    require_symbols                = true
    allow_users_to_change_password = true
    max_password_age               = 90
    password_reuse_prevention      = 24
    hard_expiry                    = false
  }
}

variable "monthly_budget_amount_usd" {
  description = "Monthly cost budget alert threshold in USD."
  type        = number
  default     = 50
}

variable "budget_notification_emails" {
  description = "Email addresses to notify on budget threshold breach."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to taggable resources."
  type        = map(string)
  default     = {}
}
