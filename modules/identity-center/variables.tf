variable "sso_instance_arn" {
  description = "ARN of the SSO instance. Get from: aws sso-admin list-instances"
  type        = string
}

variable "identity_store_id" {
  description = "Identity store ID. Get from: aws sso-admin list-instances"
  type        = string
}

variable "permission_sets" {
  description = "Permission sets backed by AWS-managed policies. Use custom_permission_sets for inline-policy or persona-specific sets."
  type = map(object({
    description         = string
    session_duration    = string
    managed_policy_arns = list(string)
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

variable "custom_permission_sets" {
  description = <<-EOT
    Persona-specific permission sets. Each set can combine AWS-managed policy
    ARNs with an inline policy (JSON). Use this for tight least-privilege roles
    like WorkloadDeveloperProd, BreakGlassAdmin, ExternalContractor, etc.
  EOT
  type = map(object({
    description         = string
    session_duration    = string
    managed_policy_arns = optional(list(string), [])
    inline_policy_json  = optional(string, "")
  }))
  default = {}
}

variable "groups" {
  description = "SSO groups to create in the Identity Store. Map of group name to display description."
  type        = map(string)
  default     = {}
}

variable "account_assignments" {
  description = <<-EOT
    SSO account assignments. principal_type = "GROUP" (recommended) or "USER".
    For GROUP assignments, set principal_id to a key from var.groups - the module
    resolves it to the created group's ID. For USER, pass the identity store user ID directly.
  EOT
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
