variable "sso_instance_arn" {
  description = "ARN of the SSO instance. Get from: aws sso-admin list-instances"
  type        = string
}

variable "identity_store_id" {
  description = "Identity store ID. Get from: aws sso-admin list-instances"
  type        = string
}

variable "permission_sets" {
  description = "Map of permission set name to config."
  type = map(object({
    description         = string
    session_duration    = string
    managed_policy_arns = list(string)
    inline_policy_json  = optional(string, "")
  }))
  default = {
    AdministratorAccess = {
      description         = "Full administrative access"
      session_duration    = "PT4H"
      managed_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
    }
    PowerUserAccess = {
      description         = "Power user without IAM/Org changes"
      session_duration    = "PT8H"
      managed_policy_arns = ["arn:aws:iam::aws:policy/PowerUserAccess"]
    }
    ReadOnlyAccess = {
      description         = "Read-only access across all services"
      session_duration    = "PT8H"
      managed_policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
    }
    SecurityAudit = {
      description         = "Security audit and compliance review access"
      session_duration    = "PT8H"
      managed_policy_arns = ["arn:aws:iam::aws:policy/SecurityAudit"]
    }
    BillingReadOnly = {
      description         = "Read-only access to billing and cost data"
      session_duration    = "PT8H"
      managed_policy_arns = ["arn:aws:iam::aws:policy/job-function/Billing"]
    }
  }
}

variable "account_assignments" {
  description = "List of SSO account assignments."
  type = list(object({
    account_id          = string
    permission_set_name = string
    principal_type      = string
    principal_id        = string
  }))
  default = []
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
