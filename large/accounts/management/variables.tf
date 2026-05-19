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

variable "accounts" {
  description = <<-EOT
    Foundation + workload accounts the org should know about. For each entry:
      - `ou_key` is required: which OU to place the account in
        (keys from modules/aws-organization default OUs: security, infrastructure, workloads, suspended)
      - Supply `email` to vend a new account via Organizations
      - Supply `account_id` to reference an existing account (no vending)
      - At least one of {email, account_id} must be set per entry

    Account creation is irreversible from Terraform - `terraform destroy` only
    suspends accounts (90-day waiting period). Email addresses must be unique
    across AWS globally.
  EOT
  type = map(object({
    ou_key     = string
    email      = optional(string, "")
    account_id = optional(string, "")
    role_name  = optional(string, "OrganizationAccountAccessRole")
  }))

  validation {
    condition = alltrue([
      for k, v in var.accounts : v.email != "" || v.account_id != ""
    ])
    error_message = "Each account must supply either email (to vend a new account) or account_id (existing)."
  }

  validation {
    condition = alltrue([
      for k, v in var.accounts : contains(["security", "infrastructure", "workloads", "suspended"], v.ou_key)
    ])
    error_message = "ou_key must be one of: security, infrastructure, workloads, suspended."
  }
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
