variable "org_name" {
  description = "Short lowercase org name used in bucket naming. Example: acme"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}$", var.org_name))
    error_message = "org_name must be lowercase alphanumeric + hyphens."
  }
}

variable "region" {
  description = "AWS region for the state bucket and DynamoDB table."
  type        = string
  default     = "us-east-1"
}

variable "repo_url" {
  description = "GitHub repo URL, used in resource tags. Example: https://github.com/acme/infra"
  type        = string
}

variable "management_account_id" {
  description = "AWS account ID of the management account."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.management_account_id))
    error_message = "management_account_id must be a 12-digit AWS account ID."
  }
}
