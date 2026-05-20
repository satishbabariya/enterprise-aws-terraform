# AFT injects these variables into every customization. See:
# https://docs.aws.amazon.com/controltower/latest/userguide/aft-account-customization-options.html#aft-provided-vars

variable "aft_request_metadata_account_name" {
  type        = string
  description = "Account name from the AFT account request"
}

variable "aft_request_metadata_account_email" {
  type        = string
  description = "Account root email"
}

variable "ct_management_account_id" {
  type        = string
  description = "Control Tower management account ID"
}

variable "log_archive_account_id" {
  type        = string
  description = "Control Tower log archive account ID"
}

variable "audit_account_id" {
  type        = string
  description = "Control Tower audit account ID"
}
