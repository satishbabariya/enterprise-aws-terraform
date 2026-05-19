variable "org_name" {
  description = "Short lowercase org name."
  type        = string
}

variable "region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "repo_url" {
  description = "GitHub repo URL."
  type        = string
}

variable "github_org" {
  description = "GitHub organization name."
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name."
  type        = string
}

variable "management_account_id" {
  description = "Management account ID."
  type        = string
}

variable "sso_instance_arn" {
  description = "From: aws sso-admin list-instances"
  type        = string
}

variable "identity_store_id" {
  description = "From: aws sso-admin list-instances"
  type        = string
}

variable "allowed_regions" {
  description = "Regions allowed by the deny-regions SCP."
  type        = list(string)
  default     = ["us-east-1", "us-west-2"]
}

variable "account_ids" {
  description = "Map of account-name to 12-digit account ID for SSO group assignments."
  type = object({
    security        = string
    log_archive     = string
    network         = string
    shared_services = string
    prod            = string
    staging         = string
    dev             = string
    sandbox         = string
  })
}

variable "external_contractor_allowed_ips" {
  description = "CIDRs from which external contractors may assume their role. Use [] to disable IP restriction."
  type        = list(string)
  default     = []
}

variable "monthly_org_budget_usd" {
  description = "Org-wide monthly budget alert threshold in USD."
  type        = number
  default     = 50000
}

variable "budget_notification_emails" {
  description = "Emails to notify on budget thresholds."
  type        = list(string)
  default     = []
}
